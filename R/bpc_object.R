#' Defines the class bpc and creates the bpc object.
#' To create we need to receive some defined parameters (the arguments from the bpc function), a lookup table and a the stanfit
#' object generated from the rstan sampling procedure
#'
#' @param fit A fit object from cmdstanr
#' @param lookup_table lookup_table dataframe. Two columns one Index the other Names where each each index will match a string in the names
#' @param cluster_lookup_table a lookup table with we have random effects
#' @param model_type the type of the model used to call stan (string)
#' @param standata a list with the data used to call the rstan::sampling procedure
#' @param call_arg a list with the arguments called from the bpc function
#' @param predictors_df the data frame of the predictors for a generalized model
#' @param predictors_lookup_table a lookup table for generalized models
#' @param predictors_matrix a matrix of predictors for generalized models
#' @param subject_predictors_lookup_table a lookup table for the subject predictors models
#' @param subject_predictors_matrix a matrix of predictors for the subject predictors matrix
#' @param used_pars an array with all the parameters set for the model
#' @param output_dir output directory for the csv files
#' @return a bpc object
#'
create_bpc_object <-
  function(fit,
           lookup_table,
           model_type,
           standata,
           call_arg,
           output_dir,
           cluster_lookup_table = NULL,
           predictors_df = NULL,
           predictors_lookup_table = NULL,
           predictors_matrix = NULL,
           subject_predictors_lookup_table = NULL,
           subject_predictors_matrix = NULL,
           used_pars='lambda') {

    hpdi <- summary_from_fit(fit, used_pars)

    #Creating the object
    obj <- list(
      Nplayers = nrow(lookup_table),
      fit=fit,
      hpdi = hpdi,
      lookup_table = lookup_table,
      cluster_lookup_table = cluster_lookup_table,
      predictors_df = predictors_df,
      predictors_lookup_table = predictors_lookup_table,
      predictors_matrix = predictors_matrix,
      model_type = model_type,
      standata = standata,
      subject_predictors_lookup_table = subject_predictors_lookup_table,
      subject_predictors_matrix = subject_predictors_matrix,
      call_arg = call_arg,
      used_pars=used_pars,
      output_dir = output_dir,
      bpcs_version =  utils::packageVersion("bpcs")
      )
    class(obj) <- "bpc"
    return(obj)
  }
