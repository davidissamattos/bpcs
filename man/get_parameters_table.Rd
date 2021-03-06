% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bpc_get_parameters.R
\name{get_parameters_table}
\alias{get_parameters_table}
\title{Publication-ready table for the parameter estimates}
\usage{
get_parameters_table(
  bpc_object,
  params = NULL,
  credMass = 0.95,
  format = "latex",
  digits = 3,
  caption = "Parameters estimates",
  HPDI = T,
  n_eff = F,
  keep_par_name = T
)
}
\arguments{
\item{bpc_object}{a bpc object}

\item{params}{a vector with the parameters to be in the table. If NULL them all will be present}

\item{credMass}{the probability mass for the credible interval}

\item{format}{A character string. same formats utilized in the knitr::kable function
\itemize{
\item 'latex': output in latex format
\item 'simple': appropriated for the console
\item 'pipe': Pandoc's pipe tables
\item 'html': for html formats
\item 'rst'
}}

\item{digits}{number of digits in the table}

\item{caption}{a string containing the caption of the table}

\item{HPDI}{a boolean if the intervals should be credible (F) or HPD intervals (T)}

\item{n_eff}{a boolean. Should the number of effective samples be presented (T) or not (F default).}

\item{keep_par_name}{keep the parameter name e.g. lambda Graff instead of Graff. Default to T. Only valid for lambda, so we can have better ranks}
}
\value{
a formatted table
}
\description{
Publication-ready table for the parameter estimates
}
\examples{
\donttest{
m<-bpc(data = tennis_agresti,
player0 = 'player0',
player1 = 'player1',
result_column = 'y',
model_type = 'bt',
solve_ties = 'none')
t<-get_parameters_table(m)
print(t)
}
}
