#' Giving a player0 an player1 scores, this functions adds one column to the data frame containing who won (0= player0 1=player1 2=tie) and another if it was a tie.
#' The ties column superseeds the y column.
#' If it was tie the y column does not matter
#' y column: (0= player0 1=player1 2=tie)
#' ties column (0=not tie, 1=tie)
#' @param d dataframe
#' @param player0_score name of the column in data
#' @param player1_score name of the column in data
#' @param solve_ties Method to solve the ties, either randomly allocate, or do nothing, or remove the row from the datasetc('random', 'none', 'remove').
#' @param win_score decides if who wins is the one that has the highest score or the lowest score
#' @return a dataframe with column 'y' that contains the results of the comparison and a ties column indicating if there was ties
#' @importFrom rlang .data
compute_scores <- function(d,
                           player0_score,
                           player1_score,
                           solve_ties = 'random',
                           win_score = 'higher') {
  d <- as.data.frame(d)


  d$diff_score <- as.vector(d[, player1_score] - d[, player0_score])
  # If higher score better than lower score for winning
  if (win_score == 'higher')
  {
    player1win <- ifelse(d$diff_score > 0, 1,
                         ifelse(d$diff_score < 0, 0, 2))
    d$y <- as.vector(player1win)
  }
  else
    #lower
  {
    player1win <- ifelse(d$diff_score < 0, 1,
                         ifelse(d$diff_score > 0, 0, 2))
    d$y <- as.vector(player1win)
  }

  # How to handle ties in the scores
  d <- fix_ties(d, solve_ties = solve_ties)


  d <- compute_ties(d, 'y')
  d <- dplyr::select(d,-.data$diff_score)
  return(as.data.frame(d))
}

#' Giving a result column we create a new column with ties (0 and 1 if it has)
#' @param d data frame
#' @param result_column column where the result is
#' @return dataframe with a column called ties
compute_ties <- function(d, result_column) {
  d <- as.data.frame(d)
  if (check_result_column(d[, result_column])) {
    d$ties <- ifelse(d[, result_column] == 2, 1, 0)
    return(as.data.frame(d))
  }
  else
    stop('compute_ties: Result column in the wrong format')

}

#' fix_ties
#' This functions provides the possible solutions for ties in the data frame
#' @param d a dataframe with the results in the y column
#' @param solve_ties method for solving ties 'random', 'none', or 'remove'
#'
#' @return a data frame with the result column y adjusted
#'@importFrom rlang .data
fix_ties <- function(d, solve_ties = 'random'){
  if (solve_ties == 'none')
  {

  }
  if (solve_ties == 'random')
  {
    for (i in 1:nrow(d)) {
      if (d$y[i] == 2)
        d$y[i] = sample(c(0, 1), replace = T, size = 1)
    }
  }
  if (solve_ties == 'remove')
  {

    d$y <- ifelse(d$y == 2, NA,d$y)
    d <- tidyr::drop_na(d, .data$y)
  }
  return(d)
}


#' Return all the name of the used parameters in a model from a bpc_object.
#' Here we exclude the log_lik and the lp__ since they are not parameters of the model
#' @param bpc_object a bpc object
#' @return a vector with the name of the parameters
get_model_parameters <- function(bpc_object) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  pars <- bpc_object$used_pars
  return(pars)
}


#' Return a data frame by resampling the posterior from a stanfit
#' Here we select a parameter, retrieve the all the posterior from the stanfit and then we resample this posterior n times
#' @references Stan Development Team (2020). RStan: the R interface to Stan. R package version 2.21.2. http://mc-stan.org/.
#' @param stanfit stanfit object
#' @param par parameter name
#' @param n number of samples
#' @return a dataframe containing the samples of the parameter. Each column is a parameter (in order of the index), each row is a sample
sample_stanfit <- function(stanfit, par, n = 100) {
  posterior <- rstan::extract(stanfit)
  posterior <- as.data.frame(posterior[[par]])
  #re sampling from the posterior
  s <- dplyr::sample_n(posterior, size = n, replace = T)
  return(as.data.frame(s))
}


#' Calculate the probability of occurrence of a in a vector x
#'
#' @param x a vector
#' @param a a value in x
#'
#' @return a value of the probability of a in vector x
calculate_prob_from_vector <- function(x, a){
  x_is_a <- x==a
  out<-length(x[x_is_a])/length(x)
  return(out)
}


