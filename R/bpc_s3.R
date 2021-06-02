#' Print method for the bpc object.
#'
#' This S3 functions only prints the mean and the HDPI values of all the parameters in the model
#' @param x a bpc object
#' @param credMass the probability mass for the credible interval
#' @param HPDI True if show HPDI interval, False to show the credible (quantile) intervals
#' @param digits number of decimal digits in the table
#' @param diagnostics show diagnostics
#' @param \dots  additional parameters for the generic print function. Not used
#' @export
#' @examples
#' \donttest{
#' m<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' print(m)
#' }
print.bpc <- function(x, credMass=0.95,  HPDI = T, digits = 3, diagnostics=TRUE, ...) {
  mess <- paste("Estimated baseline parameters with ", credMass*100,"% HPD intervals:", sep = "")
  cat(mess)
  tryCatch({
    print(get_parameters_table(
      x,
      credMass = credMass,
      format = 'simple',
      digits = digits,
      HPDI = T
    ))
    cat('NOTES:\n')
    cat('* A higher lambda indicates a higher team ability\n')

    if (stringr::str_detect(x$model_type, 'davidson')) {
      cat(
        '* Large positive values of the nu parameter indicates a high probability of tie regardless of the abilities of theplayers.\n'
      )
      cat(
        '* Large negative values of the nu parameter indicates a low probability of tie regardless of the abilities of the players.\n'
      )
      cat(
        '* Values of nu close to zero indicate that the probability of tie is more dependable on abilities of the players. If nu=0 the model reduces to the Bradley-Terry model.\n'
      )
    }
    if (stringr::str_detect(x$model_type, 'ordereffect')) {
      cat(
        '* Large positive values of the gm parameter indicate that player 1 has a disadvantage. E.g. in a home effect scenario positive values indicate a home disadvantage.\n'
      )
      cat(
        '* Large negative values of the gm parameter indicate that player 1 has an advantage. E.g. in a home effect scenario negative values indicate a home advantage.\n'
      )
      cat(
        '* Values of gm close to zero indicate that the order effect does not influence the contest. E.g. in a home effect it indicates that player 1 does not have a home advantage nor disadvantage.\n'
      )
    }
    if (stringr::str_detect(x$model_type, 'U')) {
      cat(
        '* The U_std indicates the standard deviation of the normal distribution where the parameters U[player, cluster] are drawn from. Higher values of U_std indicates a higher effect of the cluster in the team abitilies.\n'
      )
      cat(
        '* The U[player, cluster] represents the effect of a particular cluster in a particular team ability.\n'
      )
 if(diagnostics){
   cat('Basic diagnostics information: \n')
   check_convergence_diagnostics(x)
 }
    }
  },
  error = function(cond) {
    message("Error when calculating the HPDI parameters")
    message("Original error message:")
    stop(cond)
    return(NA)
  })
}

#' Summary of the model bpc model.
#'
#' * Table 1: Contains the parameter estimates and respective HPD interval
#' * Table 2: Contains the posterior probability for the combination of all players
#' * Table 3: Contains the ranking of the players' abilities based on the posterior distribution of the ranks
#' @param object bpc object
#' @param digits number of decimal digits in the table
#' @param credMass the probability mass for the credible interval
#' @param HPDI True if show HPDI interval, False to show the credible (quantile) intervals
#' @param show_probabilities should the tables of probabilities (Table 2) be displayed or not. Default to T but it is recommended to turn to F if either it has a large number of players (15+) or a large number of players and cluster, the table grows combinatorially.
#' @param \dots  additional parameters for the generic summary function. Not used.
#' @export
#' @importFrom rlang .data
#' @examples
#' \donttest{
#' m<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' summary(m)
#' }
summary.bpc <-
  function(object,
           digits = 2,
           credMass = 0.95,
           HPDI = TRUE,
           show_probabilities = TRUE,
           ...) {
    #Table with the parameter estimates and footnotes
    print.bpc(object, digits = digits, credMass = credMass, HPDI = HPDI, diagnostics=FALSE)

    #Table with the posterior probabilities
    if (show_probabilities &
        !stringr::str_detect(object$model_type, '-U') &
        !stringr::str_detect(object$model_type, '-subjectpredictors'))
    {
      cat('\n')
      cat("Posterior probabilities:\n")
      cat("These probabilities are calculated from the predictive posterior distribution\n")
      cat("for all player combinations\n")

      #we never show for random effects model
      prob_table <- tryCatch({
        get_probabilities_table(object,
                                format = 'simple',
                                digits = digits)
      },
      error = function(cond) {
        message("Error when calculating the probabilities")
        message("Original error message:")
        stop(cond)
        return(NA)
      })

      print(prob_table)

      if (stringr::str_detect(object$model_type, '-ordereffect')) {
        cat('NOTES:\n')
        cat('* These probabilies assume zero order effect (no home advantage).\n')
      }

    }


    #Table with the ranks
    cat("\nRank of the players' abilities:\n")
    cat("The rank is based on the posterior rank distribution of the lambda parameter")

    rank_players <- tryCatch({
      get_rank_of_players_table(object, format = 'simple', digits = digits)
    },
    error = function(cond) {
      message("Error when calculating the rank of the players")
      message("Original error message:")
      stop(cond)
      return(NA)
    })
    print(rank_players)

  }


#' Predict results for new data.
#'
#' This S3 function receives the bpc model and a data frame containing the same columns as the one used to fit the model.
#' It returns another data frame with with the same columns of the new data and n additional columns representing a posterior preditive distribution.
#' See the vignettes for a larger examples with the usage of this function
#' @param object a bpc object
#' @param newdata a data frame that contains columns with the same names as used to fit the data in the model.
#' @param predictors A data frame that contains the players predictors values when using a generalized model. Should be set only if using the generalized models. Only numeric values are accepted. Booleans are accepted but will be cast into integers. The first column should be for the player name, the others will be the predictors.  The column names will be used as name for the predictors
#' @param n number of time we will iterate and get the posterior. default is 100 so we dont get too many
#' @param return_matrix should we return only a matrix with the predictive values. Default F. Use this to combine with predictive posterior plots in bayesplot
#' @param model_type when dealing with some models (such as random effects) one might want to make predictions using the estimated parameters with the random effects but without specifying the specific values of random effects to predict. Therefore one can set a subset of the model to make predictions. For example: a model sampled with bt-U can be used to make predictions of the model bt only.
#' @param \dots  additional parameters for the generic predict function. Not used.
#' @return a dataframe or a matrix depending on the return_matrix parameter
#' @export
#' @examples
#' \donttest{
#' m<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' predict(m,newdata=tennis_agresti)
#'}
predict.bpc <-
  function(object,
           newdata,
           predictors = NULL,
           n = 100,
           return_matrix = T,
           model_type = NULL,
           ...) {
    if (is.null(model_type))
      model_type <- object$model_type
    else
      model_type <- model_type

    # Get some basic information for all models
    fit <- object$fit
    #standata <- object$standata #we take the list from sampling as the starting point and we modify it
    lookup_table <- object$lookup_table

    #Prepare the newdata for prediction
    newdata <- create_index_with_existing_lookup_table(
      d = newdata,
      player0 = object$call_arg$player0,
      player1 = object$call_arg$player1,
      lookup_table = lookup_table
    )

    # prepare the standata that is used in each model
    # This first step is used in all models then we customize the standata depending on the model options
    standata <- list(
      N_newdata = nrow(newdata),
      player0_indexes = as.vector(as.integer(newdata$player0_index)),
      player1_indexes = as.vector(as.integer(newdata$player1_index)),
      N_players = nrow(lookup_table)
    )

    # Add order effect or not
    if (stringr::str_detect(model_type, '-ordereffect')) {
      standata <- c(standata, list(
        use_Ordereffect = 1,
        z_player1 = as.vector(as.integer(newdata[, object$call_arg$z_player1]))
      ))
    } else{
      standata <- c(standata, list(use_Ordereffect = 0,
                                   z_player1 = numeric(0)))
    }

    if (stringr::str_detect(model_type, '-subjectpredictors')) {
      subject_predictors <- object$call_arg$subject_predictor
      subject_predictors_matrix <- as.matrix(newdata[,subject_predictors])
      standata <- c(standata,
                    list(
                      use_SubjectPredictors = 1,
                      N_SubjectPredictors = length(subject_predictors),
                      X_subject = subject_predictors_matrix
                    ))
    } else{
      standata <- c(standata,
                    list(
                      use_SubjectPredictors = 0,
                      N_SubjectPredictors = 0,
                      X_subject = matrix(NA_real_, ncol = 0, nrow = 0)
                    ))
    }


    # Add random effects or not
    if (stringr::str_detect(model_type, '-U'))
    {
      #First we create the indexes in the newdata
      cluster_lookup_table <- object$cluster_lookup_table
      cluster <- object$call_arg$cluster
      i <- 1
      for (cl in cluster) {
        newdata <- create_cluster_index_with_existing_lookup_table(
          d = newdata,
          cluster = cl,
          cluster_lookup_table = cluster_lookup_table[[i]],
          i=i
        )
        i <- i + 1
      }
      # Then we add all the clusters to standata
      if (length(cluster) == 1)
        standata <- c(
          standata,
          list(
            use_U1 = 1,
            N_U1 = nrow(cluster_lookup_table[[1]]),
            U1_indexes = as.vector(newdata$cluster1_index),
            use_U2 = 0,
            N_U2 = 0,
            U2_indexes = numeric(0),
            use_U3 = 0,
            N_U3 = 0,
            U3_indexes = numeric(0)
          )
        )
      else if (length(cluster) == 2)
        standata <- c(
          standata,
          list(
            use_U1 = 1,
            N_U1 = nrow(cluster_lookup_table[[1]]),
            U1_indexes = as.vector(newdata$cluster1_index),
            use_U2 = 1,
            N_U2 = nrow(cluster_lookup_table[[2]]),
            U2_indexes = as.vector(newdata$cluster2_index),
            use_U3 = 0,
            N_U3 = 0,
            U3_indexes = numeric(0)
          )
        )
      else if (length(cluster) == 3)
        standata <- c(
          standata,
          list(
            use_U1 = 1,
            N_U1 = nrow(cluster_lookup_table[[1]]),
            U1_indexes = as.vector(newdata$cluster1_index),
            use_U2 = 1,
            N_U2 = nrow(cluster_lookup_table[[2]]),
            U2_indexes = as.vector(newdata$cluster2_index),
            use_U3 = 1,
            N_U3 = nrow(cluster_lookup_table[[3]]),
            U3_indexes = as.vector(newdata$cluster3_index)
          )
        )
    } else{
      standata <- c(
        standata,
        list(
          use_U1 = 0,
          N_U1 = 0,
          U1_indexes = numeric(0),
          use_U2 = 0,
          N_U2 = 0,
          U2_indexes = numeric(0),
          use_U3 = 0,
          N_U3 = 0,
          U3_indexes = numeric(0)
        )
      )
    }



    # Add random effects or not
    if (stringr::str_detect(model_type, '-generalized'))
    {
      if (is.null(predictors))
        stop('For this model we require the predictors argument')
      predictors_lookup_table <- object$predictors_lookup_table

      predictor_all_columns <- colnames(predictors)
      predictors_columns <-
        predictor_all_columns[2:length(predictor_all_columns)]
      player_column <- predictor_all_columns[1]
      predictors_matrix <-
        create_predictor_matrix_with_player_lookup_table(
          d = predictors,
          player =
            player_column,
          predictors_columns =
            predictors_columns,
          lookup_table =
            lookup_table
        )

      if (!check_numeric_predictor_matrix(predictors_matrix))
        stop(
          'The predictors are mispecified. Only numeric values are accepted. Booleans are accepted but will be cast into integers'
        )

      standata <- c(standata,
                    list(
                      use_Generalized = 1,
                      K = nrow(predictors_lookup_table),
                      X = predictors_matrix
                    ))
    } else{
      standata <- c(standata, list(
        use_Generalized = 0,
        K = 0,
        X =  matrix(NA_real_, ncol = 0, nrow = 0)
      ))
    }

    if (startsWith(model_type, 'davidson'))
    {
      standata <- c(standata, list(use_Davidson = 1))
    } else{
      standata <- c(standata, list(use_Davidson = 0))
    }

    draws <-  posterior::as_draws_matrix(fit$draws())
    #downsampling
    draws<- draws[sample(nrow(draws), size = n, replace = F), ]
    pred_matrix <- btpredict(standata=standata,
                      draws=draws)
    pred_df <- cbind(newdata, as.data.frame(t(pred_matrix)))


    # After we get the posterior of the y_pred parameter we resample it
    # for most purposes  we want 1 row for each observation and 1 col for each predictive sample
    # for bayesplot we require a bit different. We need a matrix as return value with 1 col for each observation and n rows for n samples


    if (return_matrix)
    {
      return(pred_matrix)
    } else {
      pred_df <- pred_df %>% tibble::remove_rownames()
      return(as.data.frame(pred_df))
    }

  }


#' S3 plot function for the parameter plot of a bpc model
#' This is just a wrapper for the get_parameters_plot function and can be used interchangebly
#' @param x a bpc object
#' @param y Not used. Default to NULL
#' @param HPDI use HPD (TRUE) or credible intervals (FALSE) for the plots
#' @param params a vector of string for of the parameters to be plotted
#' @param title the title of the plot
#' @param subtitle optional subtitle for the plot
#' @param xaxis title of the x axis
#' @param yaxis title of the y axis
#' @param rotate_x_labels should the labels be shown horizontally (default, FALSE) or vertically (TRUE)
#' @param APA should the graphic be formatted in APA style (default TRUE)
#' @param keep_par_name keep the parameter name e.g. lambda Graff instead of Graff. Default to T. Only valid for lambda, so we can have better ranks
#' @param ... additional parameters for the generic S3 plot function. Not used.
#' @return a ggplot2 caterpillar plot
#' @export
#'
#' @examples
#' \donttest{
#' m<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' p<-get_parameters_plot(m)
#' p
#' }
plot.bpc <- function(x,
                     y = NULL,
                     HPDI = T,
                     params = c('lambda'),
                     title = 'Strength estimates',
                     subtitle = NULL,
                     xaxis = 'Player',
                     yaxis = 'Value',
                     rotate_x_labels = FALSE,
                     APA = TRUE,
                     keep_par_name = FALSE,
                     ...) {
  out <- get_parameters_plot(
    x,
    HPDI = HPDI,
    params = params,
    title = title,
    subtitle = subtitle,
    xaxis = xaxis,
    yaxis = yaxis,
    rotate_x_labels = rotate_x_labels,
    APA = APA,
    keep_par_name = keep_par_name
  )
  return(out)
}
