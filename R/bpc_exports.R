#' Retrieve the stanfit object
#'
#' @param bpc_object a bpc object
#'
#' @return stanfit object
#' @export
#'
#' @examples
get_stanfit<-function(bpc_object){
  if(class(bpc_object)!='bpc')
    stop('Error! The object is not of bpc class')
  return(bpc_object$stanfit)
}

#' Get the posterior samples for the  parameters
#'
#' @param bpc_object a bpc object
#' @param n how many times are we sampling. Default 1000
#' @param par name of the parameters to predict
#' @return Return a data frame with the posterior samples for the parameters. One column for each parameter one row for each sample
#' @export
#'
#' @examples

sample_posterior<-function(bpc_object, par='lambda', n=1000){
  #TODO: verify the random effects condition
  if(class(bpc_object)!='bpc')
    stop('Error! The object is not of bpc class')
  n<-floor(n)
  if(par=='U')
    lookup_table <- bpc_object$cluster_lookup_table
  else
    lookup_table <- bpc_object$lookup_table

  stanfit<- get_stanfit(bpc_object)
  posterior <- as.data.frame(sample_stanfit(stanfit, par=par,n=n))
  #Creating parameter name for the columns
  colnames(posterior) <- create_array_of_par_names(par,lookup_table)
  return(as.data.frame(posterior))
}

#' Return a data frame with the mean and the HPDI for all parameters
#'
#' @param bpc_object
#'
#' @return a data frame containing a column with the parameters, a column with mean and two columns with higher and lower hpdi
#' @export
#'
#' @examples
#'
get_hpdi_parameters<-function(bpc_object){
  #TODO: verify the random effects condition
  if(class(bpc_object)!='bpc')
    stop('Error! The object is not of bpc class')
  hpdi<-bpc_object$hpdi
  #excluding some parameters that are not used
  hpdi <- dplyr::filter(hpdi, !stringr::str_detect(Parameter, "log_lik"))
  hpdi <- dplyr::filter(hpdi, !stringr::str_detect(Parameter, "lp__"))
  pars<-get_model_parameters(bpc_object)
  for(i in 1:length(pars)){
    parameter <- pars[i]
    if(parameter=='U'){
      hpdi<-replace_parameter_index_with_names(hpdi,column = 'Parameter',par = parameter,bpc_object$cluster_lookup_table)
    }
    else{
      hpdi<-replace_parameter_index_with_names(hpdi, column = 'Parameter',par=parameter,bpc_object$lookup_table)
    }
  }
  return(hpdi)
}



#' Generate a ranking of the parameter strength only and based on sampling the posterior distribution
#'
#' @param bpc_object a bpc object
#' @param n Number of times we will sample the posterior
#'
#' @return a rank data frame
#' @export
#'
#' @examples
rank_parameters<-function(bpc_object,n=1000){
  if(class(bpc_object)!='bpc')
    stop('Error! The object is not of bpc class')
  s<-sample_posterior(bpc_object,par='lambda',n=n)
  s <- dplyr::mutate(s, rown = dplyr::row_number())
  wide_s <- tidyr::pivot_longer(s, cols=tidyselect::starts_with('lambda'), names_to = "Parameter", values_to = "value")
  rank_df <- wide_s %>%
    dplyr::group_by(rown) %>%
    dplyr::mutate(Rank = rank(-value, ties.method = 'random')) %>%
    dplyr::ungroup() %>%
    dplyr::select(-value) %>%
    dplyr::group_by(Parameter) %>%
    dplyr::summarise(MedianRank = median(Rank),
                     MeanRank = mean(Rank),
                     StdRank = sqrt(var(Rank))) %>%
    dplyr::arrange(MedianRank)
  return(rank_df)
}

#' Get the win/draw probabilities based on the strength parameters only
#'
#' @param bpc_object a bpc object
#'
#' @param n number of samples to draw from the posterior
#' @return a data frame with the respective probabilities
#' @export
#'
#' @examples
get_probabilities<-function(bpc_object, n=1000){
  if(class(bpc_object)!='bpc')
    stop('Error! The object is not of bpc class')
  model<-bpc_object$model_type
  stanfit<-get_stanfit(bpc_object)
  out <- NULL
  s<-sample_posterior(bpc_object,n=n)
  lookup<-bpc_object$lookup_table

  if(model=='bradleyterry')
  {
    comb <- gtools::combinations(n=bpc_object$Nplayers, r=2, v=seq(1:bpc_object$Nplayers), repeats.allowed = F)
    prob_post <- matrix(ncol=nrow(comb), nrow=n)#preallocating the space
    prob_post <- as.data.frame(prob_post)
    column_names <- c()
    player_i_name <-c()
    player_j_name <-c()
    for(j in 1:nrow(comb)){
      comb_row <- comb[j,]
      player_i <- comb_row[1]
      player_j <- comb_row[2]
      player_i_name <-c(player_i_name,lookup$Names[player_i])
      player_j_name <-c(player_j_name,lookup$Names[player_j])
      #not needed but helps debugging
      column_names <- c(column_names,paste(lookup$Names[player_i],'_beats_',lookup$Names[player_j],sep=""))
      prob_post[,j]<-inv_logit(s[,player_i]-s[,player_j])
    }
    colnames(prob_post)<-column_names
    #now that we have a posterior distribution of the probabilities lets summarize it
    prob_mean <- prob_post %>%
      dplyr::summarise_all(mean) %>%
      t() %>%
      as.vector()
    prob_hpd_lower <- prob_post %>%
      dplyr::summarise_all(HPD_lower_from_column) %>%
      t()%>%
      as.vector()
    prob_hpd_higher <- prob_post %>%
      dplyr::summarise_all(HPD_higher_from_column) %>%
      t()%>%
      as.vector()
    out<-data.frame(i=player_i_name,
                    j=player_j_name,
                    Mean=prob_mean,
                    HPD_lower=prob_hpd_lower,
                    HPD_Higher=prob_hpd_higher)
  }
  #TODO: davidsson and add draws
  if(model=='davidson')
  {

  }
  return(out)
}


#' Tiny wrapper for the PSIS-LOO-CV method from the loo package
#'
#' @param bpc_object
#'
#' @return
#' @export
#'
#' @examples
get_loo<-function(bpc_object){
  if(class(bpc_object)!='bpc')
    stop('Error! The object is not of bpc class')
  l<-loo::loo(get_stanfit(bpc_object), pars = "log_lik")
  return(l)
}

#' iny wrapper for the WAIC method from the loo package
#'
#' @param bpc_object
#'
#' @return
#' @export
#'
#' @examples
get_waic <- function(bpc_object){
  if(class(bpc_object)!='bpc')
    stop('Error! The object is not of bpc class')
  loglik<-loo::extract_log_lik(get_stanfit(bpc_object))
  waic<-loo::waic(loglik)
  return(waic)
}

#' Tiny wrapper to launch a shinystan app to investigate the MCMC
#'
#' @param bpc_object
#'
#' @return
#' @export
#'
#' @examples
launch_shinystan<-function(bpc_object){
  if(class(bpc_object)!='bpc')
    stop('Error! The object is not of bpc class')
  shinystan::launch_shinystan(get_stanfit(bpc_object))
}