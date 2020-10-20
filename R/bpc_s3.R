#' Print method for the bpc object
#'
#' @param x a bpc object
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
print.bpc <- function(x){
  cat("Estimated baseline parameters:\n")
  print(kable(get_hpdi_parameters(x),format = 'simple'))
}

#' Summary of the model bpc model
#' Contains only the parameters estimates and the respective HPD interval
#' @param x bpc object
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
summary.bpc <- function(x){
  cat("Estimated baseline parameters:\n")
  print(kable(get_hpdi_parameters(x),format = 'simple'))

  cat('\n\n')
  cat("Probability  P[i beats j]:\n")
  print(kable(get_probabilities(x),format = 'simple'))

}


#' Predict results for new data
#' This S3 function receives the bpc model and a data frame containing the same columns as the one used to fit the model.
#' It returns another data frame with with the same columns of the new data and n additional columns representing a posterior preditive distribution.
#' @param object a bpc object
#' @param newdata a data frame that contains columns with the same names as used to fit the data in the model.
#' @param n number of time we will iterate and get the posterior. default is 100 so we dont get too many
#'
#' @return
#' @export
#'
#' @examples
predict.bpc <- function(object, newdata, n=100){
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
  }
  #TODO: davidson predict
  # if(model_type=='davidson')
  # {
  # }
  #
  # After we get the posterior of the y_pred parameter we resample it and transpose it
  #so we get 1 row for each point in the new data and n columns for each time we sampled the posterior
  # we also add the columns from the original dataset to the output
  pred<-sample_stanfit(pred,par='y_pred',n=n)%>%
    t() %>%
    tibble::as_tibble()
  colnames(pred)<-paste(rep('y_pred[', n),seq(1,n),']',sep = "")
  pred<-cbind(newdata,pred)
  return(pred)
}
