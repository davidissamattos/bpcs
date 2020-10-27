#' Defines the class bpc and creates the bpc object.
#' To create we need to receive some defined parameters (the arguments from the bpc function), a lookup table and a the stanfit
#' object generated from the rstan sampling procedure
#'
#' @param stanfit Stanfit object returned by rstan::sampling
#' @param lookup_table lookup_table dataframe. Two columns one Index the other Names where each each index will match a string in the names
#' @param cluster_lookup_table a lookup table with we have random effects
#' @param model_type the type of the model used to call stan (string)
#' @param standata a list with the data used to call the rstan::sampling procedure
#' @param call_arg a list with the arguments called from the bpc function
#' @return a bpc object
#'
create_bpc_object <- function(stanfit, lookup_table, cluster_lookup_table=NULL, model_type, standata, call_arg){

  hpdi <- HPDI_from_stanfit(stanfit)

  #Creating the object
  obj <- list(Nplayers = nrow(lookup_table),
              # PlayersParametersNames=PlayersParametersNames,
              stanfit=stanfit,
              hpdi=hpdi,
              lookup_table=lookup_table,
              cluster_lookup_table = cluster_lookup_table,
              model_type=model_type,
              standata=standata,
              call_arg=call_arg)
  class(obj) <- "bpc"
  return(obj)
}
