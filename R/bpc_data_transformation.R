#' Expand aggregated data
#' Several datasets for the Bradley-Terry Model aggregate the number of wins for each player in a different column.
#' The models we provide are intended to be used in a long format. A single result for each contest.
#' This function expands datasets that have aggregated data into this long format.
#' @param d a data frame
#' @param player0 string with column name of player0
#' @param player1 string with column name of player1
#' @param wins0 string with column name of the number of wins of player 0
#' @param wins1 string with column name of the number of wins of player 1
#' @param keep an array of strings with the name of columns we want to keep in the new data frame (and repeat in every expanded row)
#' @return a data frame with the expanded dataset. It will have the columns player1, player0, y, the keep columns, and a rowid column (to make each row unique)
#' @export
#'
#' @examples
#' #Creating a simple data frame with only one row to illustrate how the function works
#' df1 <- tibble::tribble(~player0, ~player1, ~wins0, ~wins1,~cluster, 'A','B',4, 3, 'c1')
#' df2 <- expand_aggregated_data(df1,'player0', 'player1', 'wins0', 'wins1', keep=c('cluster'))
#' print(df2)
expand_aggregated_data <-
  function(d, player0, player1, wins0, wins1, keep) {
    #Currently this approach is not the most efficient, but it is also not a priority in the package
    d <- as.data.frame(d)
    n_d_rows <- nrow(d)
    n_d_columns <- ncol(d)
    n_out_col <-
      n_d_columns #win0 and win1 will become y Bbut we add the rowid in the end
    n_row_out <- sum(d[, wins0]) + sum(d[, wins1])
    out <- data.frame(matrix(ncol = n_out_col, nrow = n_row_out))
    colnames(out) <- c('player0', 'player1', 'y', keep, 'rowid')
    j <- 1
    for (i in seq_along(1:n_d_rows)) {
      current_row <- d[i, ]
      n0_rows <- current_row[1, wins0]
      n1_rows <- current_row[1, wins1]
      #First we expand the zero wins
      for (k in seq_along(1:n0_rows)) {
        out[j, 'player0'] <- current_row[1, player0]
        out[j, 'player1'] <- current_row[1, player1]
        out[j, 'y'] <- 0
        out[j, keep] <- current_row[1, keep]
        j <- j + 1
      }
      #Second we expand the one wins
      for (k in seq_along(1:n1_rows)) {
        out[j, 'player0'] <- current_row[1, player0]
        out[j, 'player1'] <- current_row[1, player1]
        out[j, 'y'] <- 1
        out[j, keep] <- current_row[1, keep]
        j <- j + 1
      }
    }
    #add the rowid column
    out[, 'rowid'] <- seq(1:n_row_out)
    return(out)
  }
