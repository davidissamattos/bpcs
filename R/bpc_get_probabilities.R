#' Get the empirical win/draw probabilities based on the ability/strength parameters.
#' Instead of calculating from the probability formula given from the model we create a predictive posterior distribution for all pair combinations and calculate the posterior wins/loose/draw
#' The function returns the mean value of win/loose/draw for the player i. To calculate for player j the probability is 1-p_i
#' @param bpc_object a bpc object
#' @param n number of samples to draw from the posterior
#' @return a list with data frame table with the respective probabilities and a matrix with the corresponding posterior
#' @importFrom rlang .data
#' @export
#' @examples
#' \donttest{
#' m<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' prob<-get_probabilities(m)
#' print(prob$Table)
#' }
get_probabilities <- function(bpc_object, n = 1000) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  model_type <- bpc_object$model_type
  stanfit <- get_stanfit(bpc_object)
  out <- NULL
  s <- get_sample_posterior(bpc_object, n = n)
  lookup <- bpc_object$lookup_table
  cluster_lookup <- bpc_object$cluster_lookup_table

  # First we get all possible combinations for all models and create a data frame
  comb <-
    gtools::combinations(
      n = bpc_object$Nplayers,
      r = 2,
      v = lookup$Names,
      repeats.allowed = F
    )
  newdata <- data.frame(comb)

  #Player 1 is i
  #Player 0 is j
  col_names <-
    c(bpc_object$call_arg$player1,
      bpc_object$call_arg$player0)
  colnames(newdata) <- col_names

  newdata <- as.data.frame(newdata)
  l <- nrow(newdata)



  predictors <- NULL
  if (stringr::str_detect(model_type, '-generalized')) {
    predictors <- bpc_object$predictors_df
  }



  # Depending on the options of model we add more or less information to the new data
  # Add order effect
  if (stringr::str_detect(model_type, '-ordereffect')) {
    z <- data.frame(rep(0, l))#assume zero order effect
    colnames(z) <- bpc_object$call_arg$z_player1
    newdata <- cbind(newdata, z)
  }


  #this should be the last model option to be evaluated
  if (stringr::str_detect(model_type, '-U')) {
    #Now we will cycle through all clusters and calculate the probability
    cluster_lookup_table <- bpc_object$cluster_lookup_table
    ncluster <- nrow(cluster_lookup_table)
    comb_newdata <- NULL
    for (i in seq(1:ncluster))
    {
      U <- data.frame(rep(cluster_lookup_table$Names[i], l))
      colnames(U) <- bpc_object$call_arg$cluster
      comb_newdata <- rbind(comb_newdata, cbind(newdata, U))
    }
    newdata <- comb_newdata
  }






  #Evaluate the predictions
  pred <-
    predict.bpc(
      bpc_object,
      newdata = newdata,
      n = n,
      predictors=predictors,
      return_matrix = T
    )
  #table t to return
  t <- NULL

  #ties are always calculated but unless in the davison they will be null
  y_pred <- pred[, startsWith(colnames(pred), "y_pred")]
  ties_pred <- pred[, startsWith(colnames(pred), "ties_pred")]

  mean_ties <- apply(ties_pred, 2, mean)
  # we should only calculate if it is not a tie for that row.
  # We remove the rows that were predicted as tie and we calculate after
  is_not_tie <- ties_pred != 1
  mean_y <- c()
  for (i in 1:ncol(y_pred)) {
    mean_i <- mean(y_pred[is_not_tie[, i], i])
    mean_y <- c(mean_y, mean_i)
  }
  mean_y <- apply(y_pred, 2, mean)

  t <- data.frame(
    i = newdata[, col_names[1]],
    j = newdata[, col_names[2]],
    i_beats_j = mean_y,
    i_ties_j = mean_ties
  )  %>%
    tibble::remove_rownames()

  #Rearranging the table if we have the clusters
  if (stringr::str_detect(model_type, '-U'))
  {
    newdata_colnames <- colnames(newdata)
    U_name <- bpc_object$call_arg$cluster
    t_names <- colnames(t)
    t <- cbind(t, newdata[,U_name])
    colnames(t) <- c(t_names,U_name)
    t <-t %>% dplyr::relocate(U_name, .after=.data$j)
  }
  #Rearranging the table if we have the ordereffect
  if (stringr::str_detect(model_type, '-ordereffect'))
  {
    newdata_colnames <- colnames(newdata)
    z_name <- bpc_object$call_arg$z_player1
    t_names <- colnames(t)
    t <- cbind(t, newdata[,z_name])
    colnames(t) <- c(t_names,z_name)
    t <-t %>% dplyr::relocate(z_name, .after=.data$j)
  }

  # if it is bt (then there are no ties) we remove the ties column
  if (startsWith(model_type, 'bt'))
  {
    t <- t %>%
      dplyr::select(-.data$i_ties_j)
  }

  out <- list(Table = t,
              Posterior = t(pred))

  return(out)
}
