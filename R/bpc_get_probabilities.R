#' Get the empirical win/draw probabilities based on the ability/strength parameters.
#' @param bpc_object a bpc object
#' @param newdata default to NULL. If used,  it will calculate the probabilities only for the newdata. Otherwise it will calculate for all combinations
#' @param n number of samples to draw from the posterior
#' @param model_type when dealing with some models (such as random effects) one might want to make predictions using the estimated parameters with the random effects but without specifying the specific values of random effects to predict. Therefore one can set a subset of the model to make predictions. For example: a model sampled with bt-U can be used to make predictions of the model bt only.
#' @return a list with data frame table with the respective probabilities and a matrix with the corresponding posterior
#' @importFrom rlang .data
get_probabilities <- function(bpc_object, newdata=NULL, n = 100, model_type=NULL) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')

  if(is.null(model_type))
    model_type <- bpc_object$model_type
  else
    model_type <- model_type

  stanfit <- get_stanfit(bpc_object)
  out <- NULL
  s <- get_sample_posterior(bpc_object, n = n)
  lookup <- bpc_object$lookup_table
  cluster_lookup <- bpc_object$cluster_lookup_table
  col_names<-NULL
  if(is.null(newdata))
  {
    if (stringr::str_detect(model_type, '-U')) {
      stop('To calculate the probabilities for models with random effects you should provide the probabilities you want in the newdata data frame')
    }
    if (stringr::str_detect(model_type, '-S')) {
      stop('To calculate the probabilities for models with subject predictors you should provide the probabilities you want in the newdata data frame')
    }

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
  }
  else{
    col_names<-colnames(newdata)
  }

  #Evaluate the predictions
  pred <-
    predict.bpc(
      bpc_object,
      newdata = newdata,
      n = n,
      predictors = predictors,
      return_matrix = T,
      model_type = model_type
    )
  #table t to return
  t <- NULL

  y_pred <- pred[, startsWith(colnames(pred), "y_pred")]

  t <- data.frame(
    i = newdata[, col_names[1]],#player1
    j = newdata[, col_names[2]],#player0
    i_beats_j = apply(y_pred, 2, calculate_prob_from_vector, 1),#prob of being 1 is i
    j_beats_i = apply(y_pred, 2, calculate_prob_from_vector, 0),#prob of being 0 is j
    i_ties_j = apply(y_pred, 2, calculate_prob_from_vector, 2)
  )  %>%
    tibble::remove_rownames()
  #just t make sure we have the correct names
  colnames(t) <- c('i', 'j', 'i_beats_j', 'j_beats_i', 'i_ties_j')

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

  #Rearranging the table if we have the subjectpredictors
  if (stringr::str_detect(model_type, '-subjectpredictors'))
  {
    newdata_colnames <- colnames(newdata)
    s_name <- bpc_object$call_arg$subject_predictors
    t_names <- colnames(t)
    t <- cbind(t, newdata[, s_name])
    colnames(t) <- c(t_names, s_name)
    t <- t %>% dplyr::relocate(s_name, .after = .data$j)
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
#' @param newdata default to NULL. If used,  it will calculate the probabilities only for the newdata. Otherwise it will calculate for all combinations
#' @param n number of samples to draw from the posterior
#' @param model_type when dealing with some models (such as random effects) one might want to make predictions using the estimated parameters with the random effects but without specifying the specific values of random effects to predict. Therefore one can set a subset of the model to make predictions. For example: a model sampled with bt-U can be used to make predictions of the model bt only.
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
#'
#' # Now we can try just specifying a few data combinations of probabilities
#' m2<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' prob<-get_probabilities_df(m2, newdata=tennis_agresti[c(1,15),])
#' print(prob)
#'
#' }
get_probabilities_df <- function(bpc_object, newdata=NULL, n = 100, model_type=NULL) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  prob <- get_probabilities(bpc_object = bpc_object, newdata=newdata, n = n, model_type=model_type)
  return(prob$Table)
}


#' Get the posterior of the probabilities
#' @param bpc_object a bpc object
#' @param newdata default to NULL. If used,  it will calculate the probabilities only for the newdata. Otherwise it will calculate for all combinations
#' @param n number of samples to draw from the posterior
#' @param model_type when dealing with some models (such as random effects) one might want to make predictions using the estimated parameters with the random effects but without specifying the specific values of random effects to predict. Therefore one can set a subset of the model to make predictions. For example: a model sampled with bt-U can be used to make predictions of the model bt only.
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
get_probabilities_posterior <- function(bpc_object,newdata=NULL, n = 1000, model_type=NULL) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  prob <- get_probabilities(bpc_object = bpc_object, newdata=newdata, n = n, model_type=model_type)
  return(prob$Posterior)
}
