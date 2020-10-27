#' Print method for the bpc object
#' We only print the parameter values and the HDPI
#' @param x a bpc object
#' @param ...  additional parameters for the generic print function
#' @return
#' @export
print.bpc <- function(x){
  cat("Estimated baseline parameters with HPD intervals:\n")
  print(knitr::kable(get_hpdi_parameters(x),format = 'simple'))
}

#' Summary of the model bpc model
#' Table 1: Contains the parameter estimates and respective HPD interval
#' Table 2: Contains the empirical probability for the combination of all players
#' @param x bpc object
#' @param ... additional parameters for the generic summary function
#' @return
#' @export
summary.bpc <- function(x){
  cat("Estimated baseline parameters with HPD intervals:\n")
  print(knitr::kable(get_hpdi_parameters(x),format = 'simple'))

  cat('\n\n')
  cat("Empirical probabilities\n")
  cat("These probabilities are calculated from the posterior predictive distribution\n")
  cat("for all player combinations\n")

  print(knitr::kable(get_probabilities(x)$Table,format = 'simple'))

}


#' Predict results for new data
#' This S3 function receives the bpc model and a data frame containing the same columns as the one used to fit the model.
#' It returns another data frame with with the same columns of the new data and n additional columns representing a posterior preditive distribution.
#' See the vignettes for a larger example with the usage of this function
#' @param object a bpc object
#' @param newdata a data frame that contains columns with the same names as used to fit the data in the model.
#' @param n number of time we will iterate and get the posterior. default is 100 so we dont get too many
#' @param return_matrix should we return only a matrix with the predictive values. Default F. Use this to combine with predictive posterior plots in bayesplot
#' This parameter also ignores the n parameter above since it passes all the predictions from stan
#' @return a dataframe or a matrix depending on the return_matrix parameter
#' @export
predict.bpc <- function(object, newdata, n=100, return_matrix=F){
  model_type<-object$model_type
  stanfit<-object$stanfit
  lookup_table<-object$lookup_table
  if(model_type=='bradleyterry')
  {
    newdata<-create_index(newdata,object$call_arg$player0, object$call_arg$player1)
    standata<-list(N_newdata = nrow(newdata),
                   player0_indexes=newdata$player0_index,
                   player1_indexes=newdata$player1_index,
                   N_players=nrow(lookup_table))
    #create a stanfit object with the predictions
    pred <- rstan::gqs(stanmodels$btpredict,
                       data=standata,
                       draws=as.matrix(stanfit))
    pred<-sample_stanfit(pred,par='y_pred',n=n)
    pred_df<-as.data.frame(pred) %>% t()
    colnames(pred_df)<-paste(rep('y_pred[', n),seq(1,n),']',sep = "")
    pred_df<-cbind(newdata,pred_df)
  }


  if(model_type=='davidson')
  {
    newdata<-create_index(newdata,object$call_arg$player0, object$call_arg$player1)
    standata<-list(N_newdata = nrow(newdata),
                   player0_indexes=newdata$player0_index,
                   player1_indexes=newdata$player1_index,
                   N_players=nrow(lookup_table))
    #create a stanfit object with the predictions
    pred <- rstan::gqs(stanmodels$davidsonpredict,
                       data=standata,
                       draws=as.matrix(stanfit))
    y_pred<-sample_stanfit(pred,par='y_pred',n=n)
    ties_pred<-sample_stanfit(pred,par='ties_pred',n=n)

    y_pred_df<-as.data.frame(y_pred) %>% t()
    colnames(y_pred_df)<-paste(rep('y_pred[', n),seq(1,n),']',sep = "")

    ties_pred_df<-as.data.frame(ties_pred) %>% t()
    colnames(ties_pred_df)<-paste(rep('ties_pred[', n),seq(1,n),']',sep = "")

    pred_df<-cbind(newdata,y_pred_df,ties_pred_df)
  }


  # After we get the posterior of the y_pred parameter we resample it
  # for most purposes  we want 1 row for each observation and 1 col for each predictive sample
  # for bayesplot we require a bit different. We need a matrix as return value with 1 col for each observation and n rows for n samples

  if(return_matrix)
  {
    return(as.matrix(pred))
  }
  else{

    return(pred_df)
  }

}
