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


#' Calculate HPDI for all parameters from a stanfit object
#' Here we use the coda package
#' @references Martyn Plummer, Nicky Best, Kate Cowles and Karen Vines (2006). CODA: Convergence Diagnosis and Output Analysis for MCMC, R News, vol 6, 7-11
#' @param stanfit a stanfit object retrived from a bpc object
#' @return a data frame with the HPDI calculated from the coda package
#' @importFrom rlang .data
HPDI_from_stanfit <- function(stanfit)
{
  hpdi <- coda::HPDinterval(coda::as.mcmc(as.data.frame(stanfit)))
  summary_stan <- rstan::summary(stanfit)
  mean_estimate <- as.data.frame(summary_stan$summary)$mean
  df <- tibble::rownames_to_column(as.data.frame(hpdi), "Parameter")
  df_hpdi <- dplyr::mutate(df, Mean = mean_estimate)
  df_hpdi <-
    dplyr::rename(df_hpdi,
                  HPD_lower = .data$lower,
                  HPD_higher = .data$upper)
  df_hpdi <-
    dplyr::select(df_hpdi,
                  .data$Parameter,
                  .data$Mean,
                  .data$HPD_lower,
                  .data$HPD_higher)
  return(as.data.frame(df_hpdi))
}
