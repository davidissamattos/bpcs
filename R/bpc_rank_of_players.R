#' Generate a ranking of the ability based on sampling the posterior distribution of the ranks.
#' This is not exported. Use either the get_rank_of_players_df or the get_rank_of_players_posterior functions
#' @param bpc_object a bpc object
#' @param n Number of times we will sample the posterior
#' @return a list containing the data frame that represents the table and a matrix containing the posterior distribution of the ranks
#' @importFrom rlang .data
#' @importFrom stats var median
get_rank_of_players <- function(bpc_object, n = 1000) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  s <- get_sample_posterior(bpc_object, par = 'lambda', n = n, keep_par_name=F)
  cols_names <- colnames(s)
  s <- dplyr::mutate(s, rown = dplyr::row_number())

  wide_s <-
    tidyr::pivot_longer(
      s,
      cols = tidyselect::all_of(cols_names),
      names_to = "Parameter",
      values_to = "value"
    )
  rank_df <- wide_s %>%
    dplyr::group_by(.data$rown) %>%
    dplyr::mutate(Rank = rank(-.data$value, ties.method = 'random')) %>%
    dplyr::ungroup() %>%
    dplyr::select(-.data$value) %>%
    dplyr::group_by(.data$Parameter) %>%
    dplyr::summarise(
      MedianRank = median(.data$Rank),
      MeanRank = mean(.data$Rank),
      StdRank = sqrt(var(.data$Rank)),
    ) %>%
    dplyr::arrange(.data$MedianRank)

  post <- wide_s %>%
    dplyr::group_by(.data$rown) %>%
    dplyr::mutate(Rank = rank(-.data$value, ties.method = 'random')) %>%
    dplyr::ungroup() %>%
    dplyr::select(-.data$value) %>%
    tidyr::pivot_wider(names_from = .data$Parameter, values_from=.data$Rank) %>%
    dplyr::select(-.data$rown) %>%
    as.matrix()

  out <- list(Table = as.data.frame(rank_df),
              Posterior = post)

  return(out)
}


#' Generate a ranking of the ability based on sampling the posterior distribution of the ranks.
#'
#' To print this object you should remove the last column PosteriorRank since it contain the whole posterior distribution for each case
#' @param bpc_object a bpc object
#' @param n Number of times we will sample the posterior
#' @return a data frame. This data frame contains the median of the rank, the mean, the standard deviation of the rank
#' @export
#' @importFrom rlang .data
#' @importFrom stats var median
#' @examples
#' \donttest{
#' m<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' rank_m<-get_rank_of_players_df(m,n=100)
#' print(rank_m)
#' }
get_rank_of_players_df <- function(bpc_object, n = 1000) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  rank_m <- get_rank_of_players(bpc_object,n=n)
  rank_df<-  rank_m$Table
  return(rank_df)
}


#' Generate a ranking of the ability based on sampling the posterior distribution of the ranks.
#'
#' To print this object you should remove the last column PosteriorRank since it contain the whole posterior distribution for each case
#' @param bpc_object a bpc object
#' @param n Number of times we will sample the posterior
#' @return a matrix containing the posterior distribution of the ranks
#' @export
#' @importFrom rlang .data
#' @importFrom stats var median
#' @examples
#' \donttest{
#' m<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' rank_m<-get_rank_of_players_posterior(m,n=100)
#' print(rank_m)
#' }
get_rank_of_players_posterior <- function(bpc_object, n = 1000) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  rank_m<-get_rank_of_players(bpc_object,n=n)
  rank_post<-  rank_m$Posterior
  return(rank_post)
}


#' Publication-ready table for the rank table
#'
#' @param bpc_object a bpc object
#' @param format A character string. same formats utilized in the knitr::kable function
#' * 'latex': output in latex format
#' * 'simple': appropriated for the console
#' * 'pipe': Pandoc's pipe tables
#' * 'html': for html formats
#' * 'rst'
#' * 'simple' appropriated for the console
#' @param digits number of digits in the table
#' @param caption a string containing the caption of the table
#' @param n number of times we are sampling the posterior
#' @return a formatted table
#' @export
#'
#' @examples
#' \donttest{
#' m<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' t<-get_rank_of_players_table(m)
#' print(t)
#' }
get_rank_of_players_table <-
  function(bpc_object,
           format = 'latex',
           digits = 3,
           caption = 'Estimated posterior ranks',
           n = 1000) {
    if (class(bpc_object) != 'bpc')
      stop('Error! The object is not of bpc class')
    t <- get_rank_of_players_df(bpc_object , n = n)
    out <-
      knitr::kable(t,
                   format = format,
                   digits = digits,
                   caption = caption,
                   booktabs = T)
    return(out)
  }


