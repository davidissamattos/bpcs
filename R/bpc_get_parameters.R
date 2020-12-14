#' Return the mean and the HPDI of the parameters of the model
#'
#' Return a data frame with the mean and with high and low 95% hpd interval or credible interval for all parameters of the model
#' @param bpc_object a bpc object
#' @param params a vector with the parameters to use. If null then all will be present
#' @param HPDI should return the HPDI or the credible intervals. Default is returning the HPDI
#' @param n_eff Should include the number of effective samples in the df
#' @param Rhat Should include the Rhat in the df
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
#' print(hpdi)}
get_parameters <- function(bpc_object, params=NULL, HPDI = TRUE, n_eff=TRUE, Rhat=FALSE) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  hpdi <- bpc_object$hpdi
  #the parameters are in order as in the hpdi
  neff_rhat <- get_stanfit_summary(bpc_object) %>%
    dplyr::select(.data$n_eff, .data$Rhat)

  #credible intervals
  credible_intervals <- get_stanfit_summary(bpc_object)[,c('2.5%', '97.5%')]

  #excluding some parameters that are not used
  hpdi <- hpdi %>%
    dplyr::filter(!stringr::str_detect(.data$Parameter, "log_lik")) %>%
    dplyr::filter(!stringr::str_detect(.data$Parameter, "lp__"))

  hpdi <- cbind(hpdi,credible_intervals, neff_rhat)

  pars <- get_model_parameters(bpc_object)
  for (i in 1:length(pars)) {
    parameter <- pars[i]
    if (parameter == 'U' & stringr::str_detect(bpc_object$model_type,'-U')) {
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
          lookup_table = bpc_object$lookup_table
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
  }

  # Now that we have replaced the parameters name let's select only the ones that the model wants
  hpdi <- hpdi %>%
    dplyr::filter(!stringr::str_detect(.data$Parameter, "_param"))

  if(!stringr::str_detect(bpc_object$model_type, "-U"))
    hpdi <- dplyr::filter(hpdi, !stringr::str_detect(.data$Parameter, "U"))
  if(!stringr::str_detect(bpc_object$model_type, "-ordereffect"))
    hpdi <- dplyr::filter(hpdi, !stringr::str_detect(.data$Parameter, "gm"))
  if(!startsWith(bpc_object$model_type, "davidson"))
    hpdi <- dplyr::filter(hpdi, !stringr::str_detect(.data$Parameter, "nu"))
  if(!stringr::str_detect(bpc_object$model_type, "-generalized"))
    hpdi <- dplyr::filter(hpdi, !startsWith(.data$Parameter, "B"))

  #Now we need to add the conditions if credible or HPD intervals
  if(HPDI){
    hpdi<- hpdi[, !(names(hpdi) %in% c('2.5%','97.5%'))]
  }
  else{
    hpdi<- dplyr::select(hpdi, -.data$HPD_lower, -.data$HPD_higher)
  }


  if(!n_eff){
    hpdi<- dplyr::select(hpdi, -.data$n_eff)
  }
  if(!Rhat){
    hpdi<- dplyr::select(hpdi, -.data$Rhat)
  }

  if(!is.null(params)){
    hpdi <- dplyr::filter(hpdi, stringr::str_detect(.data$Parameter, paste(params , collapse = "|")))
  }



  return(hpdi)
}
