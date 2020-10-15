#' Creates a bpc object based on a stanfit object and a lookup_table dataframe
#'
#' @param stanfit Stanfit object returned by rstan::sampling
#' @param lookup_table lookup_table dataframe. Two columns one Index the other Names where each each index will match a string in the names
#'
#' @return a bpc object
#'
create_bpc_object <- function(stanfit, lookup_table, model_type, standata, call_arg){
  #Pre processing
  #getting the hpdi of the  parameters
  hpdi <- HPDI_from_stanfit(stanfit)
  hpdi <- dplyr::filter(hpdi, !stringr::str_detect(Parameter, "log_lik"))
  hpdi <- dplyr::filter(hpdi, !stringr::str_detect(Parameter, "lp__"))

  #Creating the object
  obj <- list(Nplayers = nrow(lookup_table),
              # PlayersParametersNames=PlayersParametersNames,
              stanfit=stanfit,
              hpdi=hpdi,
              lookup_table=lookup_table,
              model_type=model_type,
              standata=standata,
              call_arg=call_arg)
  class(obj) <- "bpc"
  return(obj)
}
