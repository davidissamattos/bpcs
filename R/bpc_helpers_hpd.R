############ HPD functions


#' Returns the lower value of the HPD interval for a data frame column
#' @references
#' Mike Meredith and John Kruschke (2020). HDInterval: Highest (Posterior) Density Intervals. R package version 0.2.2. https://CRAN.R-project.org/package=HDInterval
#' @param column the data to calculate the HPDI
#' @param credMass Credibility mass for the interval (area contained in the interval)
#' @return the value of the lower HPD interval for that column
#' @importFrom rlang .data
HPD_lower_from_column <- function(column, credMass = 0.95) {
  hdi_col <- HDInterval::hdi(column, credMass = credMass)
  return(hdi_col[[1]])
}

#' Returns the higher value of the HPD interval for a data frame column
#' @references
#' Mike Meredith and John Kruschke (2020). HDInterval: Highest (Posterior) Density Intervals. R package version 0.2.2. https://CRAN.R-project.org/package=HDInterval
#' @param column the data to calculate the HPDI
#' @param credMass Credibility mass for the interval (area contained in the interval)
#' @return the value of the higher HPD interval for that column
#' @importFrom rlang .data
HPD_higher_from_column <- function(column, credMass = 0.95) {
  hdi_col <- HDInterval::hdi(column, credMass = credMass)
  return(hdi_col[[2]])
}


#' Summary for all parameters from a stanfit object
#' Here we use the coda package
#' @references Martyn Plummer, Nicky Best, Kate Cowles and Karen Vines (2006). CODA: Convergence Diagnosis and Output Analysis for MCMC, R News, vol 6, 7-11
#' @param fit a cmdstanr fit object retrieved from a bpc object
#' @param pars the model parameters
#' @param credMass Credibility mass for the interval
#' @return a data frame with the HPDI calculated from the coda package
#' @importFrom rlang .data
#' @importFrom stats quantile
summary_from_fit <- function(fit, pars, credMass=0.95)
{

  draws <-  posterior::as_draws_matrix(fit$draws(pars))
  diagnostics <- posterior::as_draws_matrix(fit$summary(pars))

  draws_df <- as.data.frame(draws)
  diagnostics_df <- as.data.frame(diagnostics) %>%
    dplyr::select(.data$rhat, .data$ess_bulk) %>%
    dplyr::rename('Rhat'='rhat', 'n_eff'='ess_bulk')

  mean_estimate <- as.data.frame(t(apply(draws_df, 2, mean)))
  median_estimate <- as.data.frame(t(apply(draws_df, 2, median)))
  hpdi_higher <- as.data.frame(t(apply(draws_df, 2, HPD_higher_from_column, credMass)))
  hpdi_lower <- as.data.frame(t(apply(draws_df, 2, HPD_lower_from_column, credMass)))
  q_lower <- as.data.frame(t(apply(draws_df, 2, quantile, (1-credMass)/2)))
  q_higher <- as.data.frame(t(apply(draws_df, 2, quantile, credMass+(1-credMass)/2)))


  fit_summary <- t(rbind(mean_estimate,
                       median_estimate,
                       hpdi_lower,
                       hpdi_higher,
                       q_lower,
                       q_higher))

  colnames(fit_summary) <- c("Mean", "Median", "HPD_lower", "HPD_higher", "q_lower", "q_higher")


  fit_summary <- tibble::rownames_to_column(as.data.frame(fit_summary), "Parameter")
  fit_summary <- cbind(fit_summary, diagnostics_df)

  return(as.data.frame(fit_summary))
}
