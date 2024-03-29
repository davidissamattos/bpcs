% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bpc_btpredict.R
\name{btpredict}
\alias{btpredict}
\title{This function emulates the generate quantities from stan that is not working in some cases}
\usage{
btpredict(standata, draws)
}
\arguments{
\item{standata}{a list  containing the data from stan}

\item{draws}{a matrix of draws from the parameters of the sampled model}
}
\value{
a matrix with each column represents a posterior prediction of the data and each row a predicted value
}
\description{
This function emulates the generate quantities from stan that is not working in some cases
}
