#' Get the empirical win/draw probabilities based on the ability/strength parameters.
#' @param bpc_object a bpc object
#' @param n number of samples to draw from the posterior
#' @return a list with data frame table with the respective probabilities and a matrix with the corresponding posterior
#' @importFrom rlang .data
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
      predictors = predictors,
      return_matrix = T
    )
  #table t to return
  t <- NULL

  y_pred <- pred[, startsWith(colnames(pred), "y_pred")]

  t <- data.frame(
    i = newdata[, col_names[1]],
    j = newdata[, col_names[2]],
    i_beats_j = apply(y_pred, 2, calculate_prob_from_vector, 0),
    j_beats_i = apply(y_pred, 2, calculate_prob_from_vector, 1),
    i_ties_j = apply(y_pred, 2, calculate_prob_from_vector, 2)
  )  %>%
    tibble::remove_rownames()

  #Rearranging the table if we have the clusters
  if (stringr::str_detect(model_type, '-U'))
  {
    newdata_colnames <- colnames(newdata)
    U_name <- bpc_object$call_arg$cluster
    t_names <- colnames(t)
    t <- cbind(t, newdata[, U_name])
    colnames(t) <- c(t_names, U_name)
    t <- t %>% dplyr::relocate(U_name, .after = .data$j)
  }
  #Rearranging the table if we have the ordereffect
  if (stringr::str_detect(model_type, '-ordereffect'))
  {
    newdata_colnames <- colnames(newdata)
    z_name <- bpc_object$call_arg$z_player1
    t_names <- colnames(t)
    t <- cbind(t, newdata[, z_name])
    colnames(t) <- c(t_names, z_name)
    t <- t %>% dplyr::relocate(z_name, .after = .data$j)
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



#' Get the empirical win/draw probabilities based on the ability/strength parameters.
#' @param bpc_object a bpc object
#' @param n number of samples to draw from the posterior
#' @return a data frame table with the respective probabilities
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
#' prob<-get_probabilities_df(m)
#' print(prob)
#' }
get_probabilities_df <- function(bpc_object, n = 1000) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  prob <- get_probabilities(bpc_object = bpc_object, n = n)
  return(prob$Table)
}


#' Get the posterior of the probabilities
#' @param bpc_object a bpc object
#' @param n number of samples to draw from the posterior
#' @return a matrix with the corresponding posterior
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
#' prob<-get_probabilities_posterior(m)
#' print(prob)
#' }
get_probabilities_posterior <- function(bpc_object, n = 1000) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  prob <- get_probabilities(bpc_object = bpc_object, n = n)
  return(prob$Posterior)
}


#' Get the empirical win/draw probabilities from a newdata frame. Ths allows the user to specify which specific probabilities are desired
#' @param bpc_object a bpc object
#' @param newdata a data frame equivalent to the one used to fit the model with the specific desired probabilities
#' @param n number of samples to draw from the posterior
#' @return a data frame table with the respective probabilities
#' @importFrom rlang .data
get_probabilities_newdata <- function(bpc_object, newdata, n = 1000) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')

  model_type <- bpc_object$model_type
  stanfit <- get_stanfit(bpc_object)
  out <- NULL
  s <- get_sample_posterior(bpc_object, n = n)
  lookup <- bpc_object$lookup_table
  cluster_lookup <- bpc_object$cluster_lookup_table
  col_names<-colnames(newdata)
  #Evaluate the predictions
  pred <-
    predict.bpc(
      bpc_object,
      newdata = newdata,
      n = n,
      predictors = bpc_object$predictors_df,
      return_matrix = T
    )

  y_pred <- pred[, startsWith(colnames(pred), "y_pred")]

  t <- data.frame(
    i = newdata[, col_names[1]],
    j = newdata[, col_names[2]],
    i_beats_j = apply(y_pred, 2, calculate_prob_from_vector, 0),
    j_beats_i = apply(y_pred, 2, calculate_prob_from_vector, 1),
    i_ties_j = apply(y_pred, 2, calculate_prob_from_vector, 2)
  )  %>%
    tibble::remove_rownames()

  ##Some copy and paste code but it is necessary
  ##########
  #Rearranging the table if we have the clusters
  if (stringr::str_detect(model_type, '-U'))
  {
    newdata_colnames <- colnames(newdata)
    U_name <- bpc_object$call_arg$cluster
    t_names <- colnames(t)
    t <- cbind(t, newdata[, U_name])
    colnames(t) <- c(t_names, U_name)
    t <- t %>% dplyr::relocate(U_name, .after = .data$j)
  }
  #Rearranging the table if we have the ordereffect
  if (stringr::str_detect(model_type, '-ordereffect'))
  {
    newdata_colnames <- colnames(newdata)
    z_name <- bpc_object$call_arg$z_player1
    t_names <- colnames(t)
    t <- cbind(t, newdata[, z_name])
    colnames(t) <- c(t_names, z_name)
    t <- t %>% dplyr::relocate(z_name, .after = .data$j)
  }

  # if it is bt (then there are no ties) we remove the ties column
  if (startsWith(model_type, 'bt'))
  {
    t <- t %>%
      dplyr::select(-.data$i_ties_j)
  }
  ##############


  out <- list(Table = t,
              Posterior = t(pred))

  return(out)
}


#' Get the empirical win/draw probabilities from a newdata frame. Returning a dataframe with the results
#' Instead of calculating from the probability formula given from the model we create a predictive posterior distribution for all pair combinations and calculate the posterior wins/loose/draw
#' @param bpc_object a bpc object
#' @param newdata a data frame equivalent to the one used to fit the model with the specific desired probabilities
#' @param n number of samples to draw from the posterior
#' @return a data frame table with the respective probabilities
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
#' prob<-get_probabilities_newdata_df(m, newdata=tennis_agresti[c(1,15),])
#' print(prob)
#' }
get_probabilities_newdata_df <- function(bpc_object, newdata, n = 1000) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  prob <- get_probabilities_newdata(bpc_object = bpc_object, newdata=newdata, n = n)
  return(prob$Table)
}


#' Get the empirical win/draw probabilities from a newdata frame. Returns a matrix of the posteior
#' @param bpc_object a bpc object
#' @param n number of samples to draw from the posterior
#' @param newdata a data frame equivalent to the one used to fit the model with the specific desired probabilities
#' @return a matrix with the corresponding posterior
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
#' post<-get_probabilities_newdata_posterior(m, newdata=tennis_agresti[c(1,15),])
#' print(post)
#' }
get_probabilities_newdata_posterior <- function(bpc_object, newdata, n = 1000) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  prob <- get_probabilities_newdata(bpc_object = bpc_object,newdata=newdata, n = n)
  return(prob$Posterior)
}
