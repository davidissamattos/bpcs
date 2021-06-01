#' Retrieve the cmstanr fit object
#' This object can be used with any other function or package. You can also convert it to a  stanfit objects from rstan
#' @param bpc_object a bpc object
#' @return a cmdstanr fit object
#' @export
#' @examples
#' \donttest{
#' m<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' fit<- get_fit(m)
#' print(class(fit))
#' }
get_fit <- function(bpc_object) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  return(bpc_object$fit)
}


#' Get the posterior samples for a parameter of the model.
#'
#' Return a data frame with the posterior samples for the parameters of the model
#' @param bpc_object a bpc object
#' @param n how many times are we sampling? Default 1000
#' @param par name of the parameters to predict
#' @return Return a data frame with the posterior samples for the parameters. One column for each parameter one row for each sample
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
#' s <- get_sample_posterior(m, par='lambda', n=100)
#' print(head(s))
#' }
get_sample_posterior <-
  function(bpc_object, par = 'lambda', n = 1000) {
    if (class(bpc_object) != 'bpc')
      stop('Error! The object is not of bpc class')

    n <- floor(n)
    cluster_lookup_table <- bpc_object$cluster_lookup_table
    lookup_table <- bpc_object$lookup_table
    subject_predictors_lookup_table <- bpc_object$subject_predictors_lookup_table

    fit <- get_fit(bpc_object)
    posterior <- posterior::as_draws_matrix(
      fit$draws(par)
      )
    posterior<-as.data.frame(posterior)

    posterior <- dplyr::sample_n(posterior, size = n) %>%
      tibble::remove_rownames()



    #Creating parameter name for the columns
    # The challenge here is to present a data frame with the appropriate variable names in the order given by stan.
    # We do this with the function below from helpers indexes
    colnames(posterior) <-
      create_array_of_par_names(par,
                                lookup_table = lookup_table,
                                cluster_lookup_table = cluster_lookup_table,
                                subject_predictors_lookup_table=subject_predictors_lookup_table)
    return(as.data.frame(posterior))
  }







#' Tiny wrapper for the PSIS-LOO-CV method from the loo package.
#'
#' This is used to evaluate the fit of the model using entropy criteria
#' @references
#' Vehtari A, Gelman A, Gabry J (2017). Practical Bayesian model evaluation using leave-one-out cross-validation and WAIC. Statistics and Computing_, 27, 1413-1432
#' @param bpc_object a bpc object
#' @return a loo object
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
#'  l<-get_loo(m)
#' print(l)
#' }
get_loo <- function(bpc_object) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  fit<-bpc_object$fit
  l <- fit$loo()
  return(l)
}

#' Tiny wrapper for the WAIC method from the loo package.
#'
#' This is used to evaluate the fit of the model using the Watanabe-Akaike Information criteria
#' @references
#' Gelman, Andrew, Jessica Hwang, and Aki Vehtari. Understanding predictive information criteria for Bayesian models. Statistics and computing 24.6 (2014): 997-1016.
#' @param bpc_object a bpc object
#' @return a loo object
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
#' waic<-get_waic(m)
#' print(waic)
#' }
get_waic <- function(bpc_object) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  fit<-get_fit(bpc_object)
  log_lik <- posterior::as_draws_matrix(fit$draws('log_lik'))
  waic <- loo::waic(log_lik)
  return(waic)
}

#' Tiny wrapper to launch a shinystan app to investigate the MCMC.
#' It launches a shinystan app automatically in the web browser
#' This function requires having rstan and shinystan installed
#' @param bpc_object a bpc object
#' @export
#' @examples
#' \dontrun{
#' m<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' launch_shinystan(m)
#' }
launch_shinystan <- function(bpc_object) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')

  if (!requireNamespace("rstan", quietly = TRUE)) {
    warning("The rstan package must be installed to use this functionality")
    return(NULL)
  }

  if (!requireNamespace("shinystan", quietly = TRUE)) {
    warning("The shinystan package must be installed to use this functionality")
    return(NULL)
  }

   fit<-get_fit(bpc_object)
   stanfit <- rstan::read_stan_csv(fit$output_files())
   shinystan::launch_shinystan(stanfit)
}



#' Calculate the posterior predictive distributions.
#' Helps to check the fitness of the model. Use it in conjunction with the shinystan app to visualize some nice posterior predictive plots
#'
#' @param bpc_object a bpc object
#' @param n number of times to sample from the posterior
#'
#' @return a list containing two values: y value that represents the collected data and y_pred that represents the predictive posterior matrix
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
#' pp<-posterior_predictive(m)
#' print(pp$y)
#' print(pp$y_pred)
#' }
posterior_predictive <- function(bpc_object, n = 100) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')

  y <- bpc_object$standata$y
  d <- bpc_object$call_arg$data
  pred <- predict.bpc(
    bpc_object,
    newdata = d,
    predictors = bpc_object$predictors_matrix,
    n = n,
    return_matrix = TRUE
  )
  y_pred <- pred[, startsWith(colnames(pred), "y_pred")]
  out <- list(y = y,
              y_pred = y_pred)
  return(out)
}



#' Logit function
#' @references
#' https://en.wikipedia.org/wiki/Logit
#' @param x p is a probability 0 to 1
#' @return a value between -inf and inf
#' @export
#'
#' @examples
#' logit(0.5)
#' logit(0.2)
logit <- function(x) {
  if (any(x < 0 | x > 1))
    stop('Error! x not between 0 and 1')
  y <- log(x / (1 - x))
  return(y)
}

#' Inverse logit function
#' @references
#' https://en.wikipedia.org/wiki/Logit
#' @param x is a real -inf to inf
#' @return a value between 0 and 1
#' @export
#'
#' @examples
#' inv_logit(5)
#' inv_logit(-5)
#' inv_logit(0)
inv_logit <- function(x) {
  y <- exp(x) / (1 + exp(x))
  return(y)
}


#' Thin wrapper to save the bpc model for examining later
#'
#' @param bpc_object a bpc object
#' @param filename string with the file name
#' @param path string with path following the conventions of the operating system. If not provided it will use the default folder of the csv files .bpcs in the current working directory
#' @export
save_bpc_model <- function(bpc_object, filename, path=NULL){
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  tryCatch({
    dir <- getwd()
    if(is.null(path))
        dir <- bpc$get_output_dir()
    saveRDS(bpc_object, file=file.path(dir,paste(filename,'.RDS',sep = "")))
  },
  error = function(cond) {
    message("Error when saving the model")
    message("Original error message:")
    stop(cond)
  })
}

#' Thin wrapper to load a saved bpc model for examining later
#'
#' @param file_name_with_path the file name with path following the conventions of the operating system that points to a saved bpc object including the RDS
#' @export
load_bpc_model <- function(file_name_with_path){
  bpc_object <- tryCatch({
    if(file.exists(file_name_with_path))
      readRDS(file=file.path(file_name_with_path))
    else
      stop('File does not exists')
  },
  error = function(cond) {
    message("Error when loading the model")
    message("Original error message:")
    stop(cond)
  })
  if (class(bpc_object) != 'bpc')
    stop('Error! The loaded object is not of bpc class')
  else
    return(bpc_object)
}


#' Run cmdstan diagnostics for convergence and print the results in the screen
#' Thin wrapper over cmdstanr cmdstan_diagnose() function
#' @param bpc_object a bpc object
#' @export
#' @examples
#' \donttest{
#' m<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' check_convergence_diagnostics(m)
#' }
check_convergence_diagnostics <- function(bpc_object){
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  bpc_object$fit$cmdstan_diagnose()
}

#' Get the location of the output directory for the cmdstanr csv fukes
#' @param bpc_object a bpc object
#' @export
get_output_dir <- function(bpc_object){
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  return(bpc_object$output_dir)
}


