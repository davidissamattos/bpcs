% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bpc_s3.R
\name{predict.bpc}
\alias{predict.bpc}
\title{Predict results for new data.}
\usage{
\method{predict}{bpc}(
  object,
  newdata,
  predictors = NULL,
  n = 100,
  return_matrix = T,
  model_type = NULL,
  ...
)
}
\arguments{
\item{object}{a bpc object}

\item{newdata}{a data frame that contains columns with the same names as used to fit the data in the model.}

\item{predictors}{A data frame that contains the players predictors values when using a generalized model. Should be set only if using the generalized models. Only numeric values are accepted. Booleans are accepted but will be cast into integers. The first column should be for the player name, the others will be the predictors.  The column names will be used as name for the predictors}

\item{n}{number of time we will iterate and get the posterior. default is 100 so we dont get too many}

\item{return_matrix}{should we return only a matrix with the predictive values. Default F. Use this to combine with predictive posterior plots in bayesplot}

\item{model_type}{when dealing with some models (such as random effects) one might want to make predictions using the estimated parameters with the random effects but without specifying the specific values of random effects to predict. Therefore one can set a subset of the model to make predictions. For example: a model sampled with bt-U can be used to make predictions of the model bt only.}

\item{\dots}{additional parameters for the generic predict function. Not used.}
}
\value{
a dataframe or a matrix depending on the return_matrix parameter
}
\description{
This S3 function receives the bpc model and a data frame containing the same columns as the one used to fit the model.
It returns another data frame with with the same columns of the new data and n additional columns representing a posterior preditive distribution.
See the vignettes for a larger examples with the usage of this function
}
\examples{
\donttest{
m<-bpc(data = tennis_agresti,
player0 = 'player0',
player1 = 'player1',
result_column = 'y',
model_type = 'bt',
solve_ties = 'none')
predict(m,newdata=tennis_agresti)
}
}
