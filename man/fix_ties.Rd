% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bpc_helpers.R
\name{fix_ties}
\alias{fix_ties}
\title{fix_ties
This functions provides the possible solutions for ties in the data frame}
\usage{
fix_ties(d, solve_ties = "random")
}
\arguments{
\item{d}{a dataframe with the results in the y column}

\item{solve_ties}{method for solving ties 'random', 'none', or 'remove'}
}
\value{
a data frame with the result column y adjusted
}
\description{
fix_ties
This functions provides the possible solutions for ties in the data frame
}
