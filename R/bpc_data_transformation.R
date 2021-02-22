#' Expand aggregated data
#' Several datasets for the Bradley-Terry Model aggregate the number of wins for each player in a different column.
#' The models we provide are intended to be used in a long format. A single result for each contest.
#' This function expands datasets that have aggregated data into this long format.
#' @param d a data frame
#' @param player0 string with column name of player0
#' @param player1 string with column name of player1
#' @param wins0 string with column name of the number of wins of player 0
#' @param wins1 string with column name of the number of wins of player 1
#' @param ties string with the column of the ties
#' @param keep an array of strings with the name of columns we want to keep in the new data frame (and repeat in every expanded row)
#' @return a data frame with the expanded dataset. It will have the columns player1, player0, y, the keep columns, and a rowid column (to make each row unique)
#' @export
#' @examples
#' #Creating a simple data frame with only one row to illustrate how the function works
#' df1 <- tibble::tribble(~player0, ~player1, ~wins0, ~wins1,~cluster, 'A','B',4, 3, 'c1')
#' df2 <- expand_aggregated_data(df1,'player0', 'player1', 'wins0', 'wins1', keep=c('cluster'))
#' print(df2)
expand_aggregated_data <-
  function(d, player0, player1, wins0, wins1, ties=NULL, keep=NULL) {
    #Currently this approach is not the most efficient, but more efficiency hereis also not a priority in the package
    d <- as.data.frame(d)
    n_d_rows <- nrow(d)
    n_d_columns <- ncol(d)
    column_names <- c('player0', 'player1', 'y', keep, 'rowid')
    n_out_col <- length(column_names)
    n_row_out<-NULL
    if(is.null(ties)){
      n_row_out <- sum(d[, wins0]) + sum(d[, wins1])
    } else{
      n_row_out <- sum(d[, wins0]) + sum(d[, wins1] + sum(d[,ties]))
    }
    out <- data.frame(matrix(ncol = n_out_col, nrow = n_row_out))
    colnames(out) <-column_names
    j <- 1
    for (i in seq_along(1:n_d_rows)) {
      current_row <- d[i, ]
      n0_rows <- current_row[1, wins0]
      n1_rows <- current_row[1, wins1]
      if(is.null(ties)){
        n_ties <- 0
      } else{
        n_ties <- current_row[1, ties]
      }
      #First we expand the zero wins
      for (k in seq_along(1:n0_rows)) {
        out[j, 'player0'] <- current_row[1, player0]
        out[j, 'player1'] <- current_row[1, player1]
        out[j, 'y'] <- 0
        if(!is.null(keep))
          out[j, keep] <- current_row[1, keep]
        j <- j + 1
      }
      #Second we expand the one wins
      for (k in seq_along(1:n1_rows)) {
        out[j, 'player0'] <- current_row[1, player0]
        out[j, 'player1'] <- current_row[1, player1]
        out[j, 'y'] <- 1
        if(!is.null(keep))
          out[j, keep] <- current_row[1, keep]
        j <- j + 1
      }
      #We only loop here if the ties column is not null
      if(!is.null(ties)){
        for (k in seq_along(1:n_ties)) {
          out[j, 'player0'] <- current_row[1, player0]
          out[j, 'player1'] <- current_row[1, player1]
          out[j, 'y'] <- 2
          if(!is.null(keep))
            out[j, keep] <- current_row[1, keep]
          j <- j + 1
        }
      }
    }
    #add the rowid column
    out[, 'rowid'] <- seq(1:n_row_out)
    out<-tidyr::drop_na(out)#removing columns that are added with empty values
    return(out)
  }
