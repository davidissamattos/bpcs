#' Return the mean and the HPDI/credible intervals of the parameters of the model
#'
#' Return a data frame with the mean and with high and low 95% hpd interval or credible interval for all parameters of the model
#' @param bpc_object a bpc object
#' @param params a vector with the parameters to use. If null then all will be present
#' @param HPDI should return the HPDI or the credible intervals. Default is returning the HPDI
#' @param n_eff Should include the number of effective samples in the df
#' @param Rhat Should include the Rhat in the df
#' @param credMass probability mass for the summary stats
#' @param keep_par_name keep the parameter name e.g. lambda Graff instead of Graff. Default to T. Only valid for lambda, so we can have better ranks
#' @return a data frame containing a column with the parameters, a column with mean and two columns with higher and lower intervals
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
#' hpdi<-get_parameters(m)
#' print(hpdi)
#' }
get_parameters <- function(bpc_object, params=NULL, HPDI = TRUE, credMass=0.95, n_eff=FALSE, Rhat=FALSE, keep_par_name=T) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  pars <- get_model_parameters(bpc_object)
  hpdi <- summary_from_fit(bpc_object$fit, pars=pars, credMass=credMass)
  nclusters <- length(bpc_object$cluster_lookup_table)


  #Fixing the random effects table
  if(!stringr::str_detect(bpc_object$model_type, "-U"))
    hpdi <- dplyr::filter(hpdi, !stringr::str_detect(.data$Parameter, "U"))
  if(nclusters==1){
    hpdi <- dplyr::filter(hpdi, !stringr::str_detect(.data$Parameter, "U2"))
    hpdi <- dplyr::filter(hpdi, !stringr::str_detect(.data$Parameter, "U3"))
  }
  if(nclusters==2){
    hpdi <- dplyr::filter(hpdi, !stringr::str_detect(.data$Parameter, "U3"))
  }


  if(!stringr::str_detect(bpc_object$model_type, "-ordereffect"))
    hpdi <- dplyr::filter(hpdi, !stringr::str_detect(.data$Parameter, "gm"))
  if(!stringr::str_detect(bpc_object$model_type, "-subjectpredictors"))
    hpdi <- dplyr::filter(hpdi, !startsWith(.data$Parameter, "S"))
  if(!startsWith(bpc_object$model_type, "davidson"))
    hpdi <- dplyr::filter(hpdi, !stringr::str_detect(.data$Parameter, "nu"))
  if(!stringr::str_detect(bpc_object$model_type, "-generalized"))
    hpdi <- dplyr::filter(hpdi, !startsWith(.data$Parameter, "B"))

  #Now we need to add the conditions if credible or HPD intervals
  if(HPDI){
    hpdi<- hpdi[, !(names(hpdi) %in% c('q_lower','q_higher'))]
  }
  else{
    hpdi<- dplyr::select(hpdi, -.data$HPD_lower, -.data$HPD_higher)
  }

  if(!n_eff){
    hpdi <- dplyr::select(hpdi, -.data$n_eff)
  }
  else{
    hpdi$n_eff <- floor(as.numeric(hpdi$n_eff))
  }

  if(!Rhat){
    hpdi <- dplyr::select(hpdi, -.data$Rhat)
  }
  else{
    hpdi$Rhat <- round(as.numeric(hpdi$Rhat), digits=4)
  }

  if(!is.null(params)){
    hpdi <- dplyr::filter(hpdi, stringr::str_detect(.data$Parameter, paste(params , collapse = "|")))
  }

  #FIXING NAMES


  for (i in 1:length(pars)) {
    parameter <- pars[i]
    if (parameter == 'U1' & stringr::str_detect(bpc_object$model_type,'-U') & nclusters==1) {
      hpdi <-
        replace_parameter_index_with_names(
          hpdi,
          column = 'Parameter',
          par = parameter,
          lookup_table = bpc_object$lookup_table,
          cluster_lookup_table = bpc_object$cluster_lookup_table
        )
    }
    else if (parameter == 'U2' & stringr::str_detect(bpc_object$model_type,'-U') & nclusters==2) {
      hpdi <-
        replace_parameter_index_with_names(
          hpdi,
          column = 'Parameter',
          par = parameter,
          lookup_table = bpc_object$lookup_table,
          cluster_lookup_table = bpc_object$cluster_lookup_table
        )
    }
    else if (parameter == 'U3' & stringr::str_detect(bpc_object$model_type,'-U') & nclusters==3) {
      hpdi <-
        replace_parameter_index_with_names(
          hpdi,
          column = 'Parameter',
          par = parameter,
          lookup_table = bpc_object$lookup_table,
          cluster_lookup_table = bpc_object$cluster_lookup_table
        )
    }
    else if (parameter == 'lambda') {
      hpdi <-
        replace_parameter_index_with_names(
          hpdi,
          column = 'Parameter',
          par = parameter,
          lookup_table = bpc_object$lookup_table,
          keep_par_name = keep_par_name
        )
    }
    else if (parameter == 'B' & stringr::str_detect(bpc_object$model_type,'-generalized')) {
      hpdi <-
        replace_parameter_index_with_names(
          hpdi,
          column = 'Parameter',
          par = parameter,
          lookup_table = bpc_object$lookup_table,
          predictors_lookup_table = bpc_object$predictors_lookup_table
        )
    }
    else if (parameter == 'S' & stringr::str_detect(bpc_object$model_type,'-subjectpredictors')) {
      hpdi <-
        replace_parameter_index_with_names(
          hpdi,
          column = 'Parameter',
          par = parameter,
          lookup_table = bpc_object$lookup_table,
          subject_predictors_lookup_table = bpc_object$subject_predictors_lookup_table
        )
    }
  }
  return(hpdi)
}

#' Function to retrieve a data frame with summary of the parameters
#'
#' @rdname get_parameters_df
#' @param bpc_object a bpc object
#' @param params a vector with the parameters to use. If null then all will be present
#' @param HPDI should return the HPDI or the credible intervals. Default is returning the HPDI
#' @param n_eff Should include the number of effective samples in the df
#' @param Rhat Should include the Rhat in the df
#' @param credMass probability mass for the summary stats
#' @param keep_par_name keep the parameter name e.g. lambda Graff instead of Graff. Default to T. Only valid for lambda, so we can have better ranks
#' @examples
#' \donttest{
#' m<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' param<-get_parameters_df(m)
#' print(param)
#' }
#' @export
get_parameters_df <- get_parameters



#' Return a dataframe with the posterior distribution of each parameter used in the model
#'
#' @param bpc_object a bpc object
#' @param n number of samples in the posterior
#' @return a dataframe
#' @export
#'
#' @examples
#'  \donttest{
#' m<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' param<-get_parameters_posterior(m)
#' print(head(param))
#' }
get_parameters_posterior<-function(bpc_object, n=100){
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  params <- get_model_parameters(bpc_object)
  post<-matrix(NA, nrow = n, ncol = 0)
  for(par in params){
    post <-cbind(post,get_sample_posterior(bpc_object,par = par, n=n))
  }
  return(as.data.frame(post))
}


#' Publication-ready table for the parameter estimates
#'
#' @param bpc_object a bpc object
#' @param params a vector with the parameters to be in the table. If NULL them all will be present
#' @param credMass the probability mass for the credible interval
#' @param format A character string. same formats utilized in the knitr::kable function
#' * 'latex': output in latex format
#' * 'simple': appropriated for the console
#' * 'pipe': Pandoc's pipe tables
#' * 'html': for html formats
#' * 'rst'
#' @param digits number of digits in the table
#' @param caption a string containing the caption of the table
#' @param HPDI a boolean if the intervals should be credible (F) or HPD intervals (T)
#' @param n_eff a boolean. Should the number of effective samples be presented (T) or not (F default).
#' @param keep_par_name keep the parameter name e.g. lambda Graff instead of Graff. Default to T. Only valid for lambda, so we can have better ranks
#' @return a formatted table
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
#' t<-get_parameters_table(m)
#' print(t)
#' }
get_parameters_table <-
  function(bpc_object,
           params=NULL,
           credMass = 0.95,
           format = 'latex',
           digits = 3,
           caption = 'Parameters estimates',
           HPDI = T,
           n_eff = F,
           keep_par_name=T) {
    if (class(bpc_object) != 'bpc')
      stop('Error! The object is not of bpc class')
    t <- get_parameters(bpc_object, credMass=credMass, params=params, HPDI = HPDI,n_eff = n_eff,keep_par_name = keep_par_name)
    out <-
      knitr::kable(t,
                   format = format,
                   digits = digits,
                   caption = caption,
                   booktabs = T)
    return(out)
  }


