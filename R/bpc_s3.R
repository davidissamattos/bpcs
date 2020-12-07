#' Print method for the bpc object.
#'
#' This S3 functions only prints the mean and the HDPI values of all the parameters in the model
#' @param x a bpc object
#' @param \dots  additional parameters for the generic print function
#' @param digits number of decimal digits in the table
#' @export
#' @examples
#' \donttest{
#' m<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' #' print(m)
#' }
print.bpc <- function(x, digits = 3, ...) {
  cat("Estimated baseline parameters with HPD intervals:\n")
  hpdi <- tryCatch({
    get_hpdi_parameters(x)
  },
  error = function(cond) {
    message("Error when calculating the HPDI parameters")
    message("Original error message:")
    stop(cond)
    return(NA)
  })
  print(knitr::kable(hpdi, format = 'simple', digits = digits))
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

  }


}

#' Summary of the model bpc model.
#'
#' * Table 1: Contains the parameter estimates and respective HPD interval
#' * Table 2: Contains the posterior probability for the combination of all players
#' * Table 3: Contains the ranking of the players' abilities based on the posterior distribution of the ranks
#' @param object bpc object
#' @param digits number of decimal digits in the table
#' @param \dots  additional parameters for the generic summary function
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
summary.bpc <- function(object, digits = 2, ...) {
  #Table with the parameter estimates and footnotes
  print(object, digits = digits)


  #TODO: we commented out the posterior probabilities table until we fix the get_probabilities
  #Table with the posterior probabilities
  cat('\n\n')
  cat("Posterior probabilities:\n")
  cat("These probabilities are calculated from the predictive posterior distribution\n")
  cat("for all player combinations\n")

  prob_table <- tryCatch({
    get_probabilities(object)
  },
  error = function(cond) {
    message("Error when calculating the probabilities")
    message("Original error message:")
    stop(cond)
    return(NA)
  })

  print(knitr::kable(prob_table$Table,
                     format = 'simple',
                     digits = digits))

  if (stringr::str_detect(object$model_type, 'ordereffect')) {
    cat('NOTES:\n')
    cat('* These probabilies assume zero order effect (no home advantage).\n')
  }

  #Table with the ranks
  cat('\n\n')
  cat("Rank of the players' abilities:\n")
  cat("The rank is based on the posterior rank distribution of the lambda parameter\n")

  rank_players <- tryCatch({
    get_rank_of_players(object)
  },
  error = function(cond) {
    message("Error when calculating the rank of the players")
    message("Original error message:")
    stop(cond)
    return(NA)
  })

  rank_of_players <-
    rank_players %>% dplyr::select(.data$Parameter,
                                   .data$MedianRank,
                                   .data$MeanRank,
                                   .data$StdRank)
  print(knitr::kable(rank_of_players, format = 'simple', digits = digits))

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
#' This parameter also ignores the n parameter above since it passes all the predictions from stan
#' @param \dots  additional parameters for the generic print function
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

#TODO: fix B variable in btpredict and the predictors in get_probabilities
predict.bpc <-
  function(object,
           newdata,
           predictors = NULL,
           n = 100,
           return_matrix = F,
           ...) {
    # Get some basic information for all models
    model_type <- object$model_type
    stanfit <- object$stanfit
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

    # Add random effects or not
    if (stringr::str_detect(model_type, '-U'))
    {
      cluster_lookup_table <- object$cluster_lookup_table
      newdata <-
        create_cluster_index_with_existing_lookup_table(
          d = newdata,
          cluster = object$call_arg$cluster,
          cluster_lookup_table = cluster_lookup_table
        )
      standata <- c(standata, list(
        use_U = 1,
        N_U = nrow(cluster_lookup_table),
        U_indexes = as.vector(as.integer(newdata$cluster_index))
      ))
    } else{
      standata <- c(standata, list(
        use_U = 0,
        N_U = 0,
        U_indexes = numeric(0)
      ))
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
      new_predictors_lookup_table <-
        create_predictors_lookup_table(predictors_columns)

      if (!dplyr::all_equal(new_predictors_lookup_table, predictors_lookup_table))
        stop(
          'The predictor data frame is specified differently than the predictors data frame used to generate the model. We found different predictors or predictors in different order. The columns should be in the same order and contain only the predictors and the players name'
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


    #This is a weird fix do to a possible bugs in rstan
    #rstan does not return parameters with zero dimension
    #gqs requires all parameters including those with zero dimensions
    # I am keeping this here just in case for the future

    #create a stanfit object with the predictions
    # draws <- as.matrix(stanfit)
    # nrows_draws <- nrow(draws)
    # pars_draws <- colnames(draws)
    # #lambda is always there so we don't need to worry about it
    # all_pars <- c('gm_param','U_std_param','U','nu_param')
    # not_in_draws <- setdiff(all_pars, pars_draws)#which of the allpars are not in pars_draws
    # for(i in 1:length(not_in_draws)){ #adding fake sample to the stanfit matrix
    #   draws<-cbind(not_in_draws[i]=rep(0,nrows_draws))
    # }


    draws <- as.matrix(stanfit)
    pred <- rstan::gqs(stanmodels$btpredict,
                       data = standata,
                       draws = draws)

    pred_df <- NULL #the return object

    # Now we compute the predictions
    y_pred <- sample_stanfit(pred, par = 'y_pred', n = n)
    ties_pred <- sample_stanfit(pred, par = 'ties_pred', n = n)
    y_pred_df <- as.data.frame(y_pred) %>% t()
    colnames(y_pred_df) <-
      paste(rep('y_pred[', n), seq(1, n), ']', sep = "")
    ties_pred_df <- as.data.frame(ties_pred) %>% t()
    colnames(ties_pred_df) <-
      paste(rep('ties_pred[', n), seq(1, n), ']', sep = "")
    pred_df <- cbind(newdata, y_pred_df, ties_pred_df)



    # After we get the posterior of the y_pred parameter we resample it
    # for most purposes  we want 1 row for each observation and 1 col for each predictive sample
    # for bayesplot we require a bit different. We need a matrix as return value with 1 col for each observation and n rows for n samples

    if (return_matrix)
    {
      return(as.matrix(pred))
    }
    else{
      pred_df <- pred_df %>% tibble::remove_rownames()
      return(as.data.frame(pred_df))
    }

  }
