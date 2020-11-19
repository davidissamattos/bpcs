#' Get the empirical win/draw probabilities based on the ability/strength parameters.
#' Instead of calculating from the probability formula given from the model we create a predictive posterior distribution for all pair combinations and calculate the posterior wins/loose/draw
#' The function returns the mean value of win/loose/draw for the player i. To calculate for player j the probability is 1-p_i
#' @param bpc_object a bpc object
#' @param n number of samples to draw from the posterior
#' @return a list with data frame table with the respective probabilities and a matrix with the corresponding posterior
#' @export
#' @examples
#' m<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' prob<-get_probabilities(m)
#' print(prob$Table)
get_probabilities <- function(bpc_object, n = 1000) {
  if (class(bpc_object) != 'bpc')
    stop('Error! The object is not of bpc class')
  model <- bpc_object$model_type
  stanfit <- get_stanfit(bpc_object)
  out <- NULL
  s <- get_sample_posterior(bpc_object, n = n)
  lookup <- bpc_object$lookup_table
  cluster_lookup <- bpc_object$cluster_lookup_table
  # Here we will get a Bayesian estimated probability of winning/ties
  if (model == 'bt')
  {
    #first we create a data frame of new data for the BT model
    comb <-
      gtools::combinations(
        n = bpc_object$Nplayers,
        r = 2,
        v = lookup$Names,
        repeats.allowed = F
      )
    newdata <- data.frame(comb)
    #Player 1 is i
    #Player 0 is j
    col_names <-
      c(bpc_object$call_arg$player1,
        bpc_object$call_arg$player0)
    colnames(newdata) <- col_names
    newdata<-as.data.frame(newdata)
    pred <-
      predict.bpc(
        bpc_object,
        newdata = newdata,
        n = n,
        return_matrix = T
      )
    mean_pred <- apply(pred, 2, mean)

    t <- data.frame(i = newdata[, col_names[1]],
                    j = newdata[, col_names[2]],
                    i_beats_j = mean_pred)  %>%
      tibble::remove_rownames()
    out <- list(Table = t,
                Posterior = t(pred))
  }
  if (model == 'davidson')
  {
    #first we create a data frame of new data for the davidson model
    comb <-
      gtools::combinations(
        n = bpc_object$Nplayers,
        r = 2,
        v = lookup$Names,
        repeats.allowed = F
      )
    newdata <- data.frame(comb)
    #Player 1 is i
    #Player 0 is j
    col_names <-
      c(bpc_object$call_arg$player1,
        bpc_object$call_arg$player0)
    colnames(newdata) <- col_names
    newdata<-as.data.frame(newdata)
    pred <-
      predict.bpc(
        bpc_object,
        newdata = newdata,
        n = n,
        return_matrix = T
      )

    y_pred <- pred[, startsWith(colnames(pred), "y_pred")]
    ties_pred <- pred[, startsWith(colnames(pred), "ties_pred")]

    mean_ties <- apply(ties_pred, 2, mean)
    # we should only calculate if it is not a tie for that row.
    # We remove the rows that were predicted as tie and we calculate after
    is_not_tie <- ties_pred != 1
    mean_y <- c()
    for (i in 1:ncol(y_pred)) {
      mean_i <- mean(y_pred[is_not_tie[, i], i])
      mean_y <- c(mean_y, mean_i)
    }

    mean_y <- apply(y_pred, 2, mean)
    t <- data.frame(
      i = newdata[, col_names[1]],
      j = newdata[, col_names[2]],
      i_beats_j = mean_y,
      i_ties_j = mean_ties
    )  %>%
      tibble::remove_rownames()
    out <- list(Table = t,
                Posterior = t(pred))
  }
  if (model == 'btordereffect')
  {
    #first we create a data frame of new data for the BT model
    comb <-
      gtools::combinations(
        n = bpc_object$Nplayers,
        r = 2,
        v = lookup$Names,
        repeats.allowed = F
      )
    l <- nrow(comb)
    newdata <- data.frame(comb)
    z <- rep(0, l)#assume zero order effect
    newdata <- cbind(comb, z)
    #Player 1 is i
    #Player 0 is j
    col_names <-
      c(
        bpc_object$call_arg$player1,
        bpc_object$call_arg$player0,
        bpc_object$call_arg$z_player1
      )
    colnames(newdata) <- col_names
    newdata<-as.data.frame(newdata)
    pred <-
      predict.bpc(
        bpc_object,
        newdata = newdata,
        n = n,
        return_matrix = T
      )
    mean_pred <- apply(pred, 2, mean)

    t <- data.frame(i = newdata[, col_names[1]],
                    j = newdata[, col_names[2]],
                    i_beats_j = mean_pred)  %>%
      tibble::remove_rownames()
    out <- list(Table = t,
                Posterior = t(pred))
  }
  if (model == 'davidsonordereffect')
  {
    #first we create a data frame of new data for the model
    comb <-
      gtools::combinations(
        n = bpc_object$Nplayers,
        r = 2,
        v = lookup$Names,
        repeats.allowed = F
      )
    l <- nrow(comb)
    newdata <- data.frame(comb)
    z <- rep(0, l)#assume zero order effect
    newdata <- cbind(comb, z)
    #Player 1 is i
    #Player 0 is j
    col_names <-
      c(
        bpc_object$call_arg$player1,
        bpc_object$call_arg$player0,
        bpc_object$call_arg$z_player1
      )
    colnames(newdata) <- col_names
    newdata<-as.data.frame(newdata)
    pred <-
      predict.bpc(
        bpc_object,
        newdata = newdata,
        n = n,
        return_matrix = T
      )
    y_pred <- pred[, startsWith(colnames(pred), "y_pred")]
    ties_pred <- pred[, startsWith(colnames(pred), "ties_pred")]

    mean_ties <- apply(ties_pred, 2, mean)
    # we should only calculate if it is not a tie for that row.
    # We remove the rows that were predicted as tie and we calculate after
    is_not_tie <- ties_pred != 1
    mean_y <- c()
    for (i in 1:ncol(y_pred)) {
      mean_i <- mean(y_pred[is_not_tie[, i], i])
      mean_y <- c(mean_y, mean_i)
    }

    mean_y <- apply(y_pred, 2, mean)
    t <- data.frame(
      i = newdata[, col_names[1]],
      j = newdata[, col_names[2]],
      i_beats_j = mean_y,
      i_ties_j = mean_ties
    )  %>%
      tibble::remove_rownames()
    out <- list(Table = t,
                Posterior = t(pred))
  }


  if (model == 'btU')
  {
    #first we create a data frame of new data for the BT model
    comb <-
      gtools::combinations(
        n = bpc_object$Nplayers,
        r = 2,
        v = lookup$Names,
        repeats.allowed = F
      )
    l <- nrow(comb)
    comb_df <- data.frame(comb)
    #Now we will cycle through all clusters and calculate the probability
    cluster_lookup_table <- bpc_object$cluster_lookup_table
    ncluster <- nrow(cluster_lookup_table)
    newdata <- NULL
    for (i in seq(1:ncluster))
    {
      U <- rep(cluster_lookup_table$Names[i], l)
      newdata <- rbind(newdata, cbind(comb_df, U))
    }
    #Player 1 is i
    #Player 0 is j
    col_names <-
      c(
        bpc_object$call_arg$player1,
        bpc_object$call_arg$player0,
        bpc_object$call_arg$cluster
      )
    colnames(newdata) <- col_names
    newdata<-as.data.frame(newdata)
    pred <-
      predict.bpc(
        bpc_object,
        newdata = newdata,
        n = n,
        return_matrix = T
      )
    mean_pred <- apply(pred, 2, mean)

    t <- data.frame(
      i = newdata[, col_names[1]],
      j = newdata[, col_names[2]],
      U = newdata[, col_names[3]],
      i_beats_j = mean_pred
    )  %>%
      tibble::remove_rownames()
    out <- list(Table = t,
                Posterior = t(pred))
  }

  if (model == 'davidsonU')
  {
    #first we create a data frame of new data for the BT model
    comb <-
      gtools::combinations(
        n = bpc_object$Nplayers,
        r = 2,
        v = lookup$Names,
        repeats.allowed = F
      )
    l <- nrow(comb)
    comb_df <- data.frame(comb)
    #Now we will cycle through all clusters and calculate the probability
    cluster_lookup_table <- bpc_object$cluster_lookup_table
    ncluster <- nrow(cluster_lookup_table)
    newdata <- NULL
    for (i in seq(1:ncluster))
    {
      U <- rep(cluster_lookup_table$Names[i], l)
      newdata <- rbind(newdata, cbind(comb_df, U))
    }
    #Player 1 is i
    #Player 0 is j
    col_names <-
      c(
        bpc_object$call_arg$player1,
        bpc_object$call_arg$player0,
        bpc_object$call_arg$cluster
      )
    colnames(newdata) <- col_names
    newdata<-as.data.frame(newdata)
    pred <-
      predict.bpc(
        bpc_object,
        newdata = newdata,
        n = n,
        return_matrix = T
      )
    y_pred <- pred[, startsWith(colnames(pred), "y_pred")]
    ties_pred <- pred[, startsWith(colnames(pred), "ties_pred")]

    mean_ties <- apply(ties_pred, 2, mean)
    # we should only calculate if it is not a tie for that row.
    # We remove the rows that were predicted as tie and we calculate after
    is_not_tie <- ties_pred != 1
    mean_y <- c()
    for (i in 1:ncol(y_pred)) {
      mean_i <- mean(y_pred[is_not_tie[, i], i])
      mean_y <- c(mean_y, mean_i)
    }

    mean_y <- apply(y_pred, 2, mean)
    t <- data.frame(
      i = newdata[, col_names[1]],
      j = newdata[, col_names[2]],
      i_beats_j = mean_y,
      i_ties_j = mean_ties
    )  %>%
      tibble::remove_rownames()
    out <- list(Table = t,
                Posterior = t(pred))
  }

  if (model == 'btgeneralized')
  {
    #first we create a data frame of new data for the BT model
    comb <-
      gtools::combinations(
        n = bpc_object$Nplayers,
        r = 2,
        v = lookup$Names,
        repeats.allowed = F
      )
    newdata <- data.frame(comb)
    #Player 1 is i
    #Player 0 is j
    col_names <-
      c(bpc_object$call_arg$player1,
        bpc_object$call_arg$player0)
    colnames(newdata) <- col_names
    newdata<-as.data.frame(newdata)
    pred <-
      predict.bpc(
        bpc_object,
        newdata = newdata,
        predictors = bpc_object$predictors_df,
        n = n,
        return_matrix = T
      )
    mean_pred <- apply(pred, 2, mean)

    t <- data.frame(i = newdata[, col_names[1]],
                    j = newdata[, col_names[2]],
                    i_beats_j = mean_pred)  %>%
      tibble::remove_rownames()
    out <- list(Table = t,
                Posterior = t(pred))
  }
  if (model == 'davidsongeneralized')
  {
    #first we create a data frame of new data for the davidson model
    comb <-
      gtools::combinations(
        n = bpc_object$Nplayers,
        r = 2,
        v = lookup$Names,
        repeats.allowed = F
      )
    newdata <- data.frame(comb)
    #Player 1 is i
    #Player 0 is j
    col_names <-
      c(bpc_object$call_arg$player1,
        bpc_object$call_arg$player0)
    colnames(newdata) <- col_names
    newdata<-as.data.frame(newdata)
    pred <-
      predict.bpc(
        bpc_object,
        newdata = newdata,
        predictors = bpc_object$predictors_df,
        n = n,
        return_matrix = T
      )

    y_pred <- pred[, startsWith(colnames(pred), "y_pred")]
    ties_pred <- pred[, startsWith(colnames(pred), "ties_pred")]

    mean_ties <- apply(ties_pred, 2, mean)
    # we should only calculate if it is not a tie for that row.
    # We remove the rows that were predicted as tie and we calculate after
    is_not_tie <- ties_pred != 1
    mean_y <- c()
    for (i in 1:ncol(y_pred)) {
      mean_i <- mean(y_pred[is_not_tie[, i], i])
      mean_y <- c(mean_y, mean_i)
    }

    mean_y <- apply(y_pred, 2, mean)
    t <- data.frame(
      i = newdata[, col_names[1]],
      j = newdata[, col_names[2]],
      i_beats_j = mean_y,
      i_ties_j = mean_ties
    )  %>%
      tibble::remove_rownames()
    out <- list(Table = t,
                Posterior = t(pred))
  }


  return(out)
}
