#TODO: fix code for more than 1 cluster

######## Index and lookup table functions

#' Create a lookup table of names and indexes
#' Note that the indexes will be created in the order they appear. For string this doesnt make much difference but for numbers the index might be different than the actual number that appears in names
#' @param d A data frame containing the observations. The other parameters specify the name of the columns
#' @param player0 The name of the column of data  contains player0
#' @param player1 The name of the column of data  contains player0
#'
#' @return A dataframe of a lookup table with columns Names and Index
create_index_lookuptable <- function(d, player0, player1) {
  d <- as.data.frame(d)
  p0_names <- unique(d[, player0])
  p1_names <- unique(d[, player1])
  player_names <- unique(c(p0_names, p1_names))
  player_index <-
    seq(1:length(player_names)) #sequential indexing starting with 1

  #Now we have a lookup table to convert the indexes
  lookup_table <-
    data.frame(Names = player_names, Index = player_index)
  return(as.data.frame(lookup_table))
}

#' Create a lookup table of names and indexes
#' Note that the indexes will be created in the order they appear. For string this does not make much difference but for numbers the index might be different than the actual number that appears in names
#' @param d A data frame containing the observations. The other parameters specify the name of the columns
#' @param cluster A string with the name of the cluster variable
#'
#' @return A dataframe of a lookup table with columns Names and Index
create_index_cluster_lookuptable <- function(d, cluster) {
  d <- as.data.frame(d)
  cluster_names <- unique(d[, cluster])
  cluster_index <-
    seq(1:length(cluster_names)) #sequential indexing starting with 1
  #Now we have a lookup table to convert the indexes
  cluster_lookup_table <-
    data.frame(Names = cluster_names, Index = cluster_index)
  return(as.data.frame(cluster_lookup_table))
}

#' Receives two columns with player names and returns a data frame with the relevant index columns based on a given lookup table
#'
#' @param d a data frame
#' @param player0 The name of the column of data data contains player0
#' @param player1 The name of the column of data data contains player1
#' @param lookup_table a lookup table data frame
#' @return A dataframe with the additional columns 'player0_index' and 'player1_index' that contains the indexes
match_player_names_to_lookup_table <-
  function(d, player0, player1, lookup_table)
  {
    #https://stackoverflow.com/questions/35636315/replace-values-in-a-dataframe-based-on-lookup-table
    player0_index <-
      lookup_table$Index[match(unlist(d[, player0]), lookup_table$Names)]
    player1_index <-
      lookup_table$Index[match(unlist(d[, player1]), lookup_table$Names)]
    d$player0_index <- player0_index
    d$player1_index <- player1_index
    return(d)
  }


#' Receives a column with cluster names and returns a data frame with the relevant index column based on a given cluster lookup table
#'
#' @param d a data frame
#' @param cluster The name of the column of data data contains player0
#' @param cluster_lookup_table a lookup table for the cluster
#' @param i number of the cluster
#' @return A dataframe with the additional columns 'cluster_index' that contains the indexes
match_cluster_names_to_cluster_lookup_table <-
  function(d, cluster , cluster_lookup_table, i)
  {
    cluster_index <-
      cluster_lookup_table$Index[match(unlist(d[, cluster]), cluster_lookup_table$Names)]
    d[, paste('cluster', i, '_index', sep = "")] <- cluster_index
    return(d)
  }


#' Create two columns with the indexes for the names of the players
#' Here we create a new lookup table. Should be used when sampling the parameters
#' @param d A data frame containing the observations. The other parameters specify the name of the columns
#' @param player0 The name of the column of data data contains player0
#' @param player1 The name of the column of data data contains player0
#' @return A dataframe with the additional columns 'player0_index' and 'player1_index' that contains the indexes
create_index <- function(d, player0, player1) {
  d <- as.data.frame(d)

  #Now we have a lookup table to convert the indexes
  lookup_table <-
    create_index_lookuptable(d, player0 = player0, player1 = player1)
  d <- match_player_names_to_lookup_table(d,
                                          player0 = player0,
                                          player1 = player1,
                                          lookup_table = lookup_table)

  #We return a data frame with the indexes
  return(as.data.frame(d))
}


#' Create two columns with the indexes for the names of the players
#' Here we create a new lookup table. Should be used when sampling the parameters
#' @param d A data frame containing the observations. The other parameters specify the name of the columns
#' @param cluster The name of the column of data data contains player0
#' @param i number of the cluster (1 or 2)
#' @return A dataframe with the additional columns 'cluster_index'
create_cluster_index <- function(d, cluster, i) {
  d <- as.data.frame(d)
  #Now we have a lookup table to convert the indexes
  cluster_lookup_table <-
    create_index_cluster_lookuptable(d, cluster)
  d <- match_cluster_names_to_cluster_lookup_table(d,
                                                   cluster = cluster,
                                                   cluster_lookup_table = cluster_lookup_table,
                                                   i = i)
  #We return a data frame with the indexes
  return(as.data.frame(d))
}


#' Receives one column with player names and returns a data frame with the relevant index columns based on a given lookup table
#' To be used with the predictors data frame
#' @param d a data frame of the predictors
#' @param player The name of the column of data data contains the player
#' @param lookup_table a lookup table data frame
#' @return A dataframe with the additional column 'player_index'
create_index_predictors_with_lookup_table <-
  function(d, player, lookup_table)
  {
    #https://stackoverflow.com/questions/35636315/replace-values-in-a-dataframe-based-on-lookup-table
    d <- as.data.frame(d)
    player_index <-
      lookup_table$Index[match(unlist(d[, player]), lookup_table$Names)]
    d$player_index <- player_index
    return(d)
  }

#' Receives a predictor dataframe, a string with the column of the player, a vector of strings with the columns for the predictors and a lookup table and returns an ordered matrix for Stan
#' To be used with the predictors data frame
#' @param d a data frame of the predictors
#' @param player The name of the column of data data contains the player
#' @param predictors_columns a vector with strings containing the columns for the predictors
#' @param lookup_table a lookup table data frame
#' @return A matrix to be used in stan
#' @importFrom rlang .data
create_predictor_matrix_with_player_lookup_table <-
  function(d,
           player,
           predictors_columns,
           lookup_table) {
    d <- as.data.frame(d)
    d <-
      create_index_predictors_with_lookup_table(d, player, lookup_table)
    d <- dplyr::arrange(d, .data$player_index)
    out_m <- as.matrix(d[, predictors_columns])
  }

#' Receives a vector with predictors strings (the column names) and returns a predictor_lookup_table
#' @param predictors_columns a vector with strings containing the columns for the predictors
#' @return A matrix to be used in stan
create_predictors_lookup_table <- function(predictors_columns) {
  predictors_index <-
    seq(1:length(predictors_columns)) #sequential indexing starting with 1
  #Now we have a lookup table to convert the indexes
  lookup_table <-
    data.frame(Names = predictors_columns, Index = predictors_index)
  return(lookup_table)
}





#' Create two columns with the indexes for the names
#' Here we use an existing lookup table. Should be used in predicting
#' @param d A data frame containing the observations. The other parameters specify the name of the columns
#' @param player0 The name of the column of data data contains player0
#' @param player1 The name of the column of data data contains player0
#' @param lookup_table lookup_table a lookup table data frame
#' @return A dataframe with the additional columns 'player0_index' and 'player1_index' that contains the indexes
create_index_with_existing_lookup_table <-
  function(d, player0, player1, lookup_table) {
    d <- match_player_names_to_lookup_table(d,
                                            player0 = player0,
                                            player1 = player1,
                                            lookup_table = lookup_table)
    return(d)
  }



#' Create two columns with the indexes for the names
#' Here we use an existing lookup table. Should be used in predicting
#' @param d A data frame containing the observations. The other parameters specify the name of the columns
#' @param cluster The name of the column of data data contains player0
#' @param cluster_lookup_table a lookup table for the cluster
#' @param i index of the cluster in the list (1, 2, 3)
#' @return A dataframe with the additional columns 'player0_index' and 'player1_index' that contains the indexes
create_cluster_index_with_existing_lookup_table <-
  function(d, cluster, cluster_lookup_table, i) {
    d <-
      match_cluster_names_to_cluster_lookup_table(d,
                                                  cluster = cluster,
                                                  cluster_lookup_table = cluster_lookup_table,
                                                  i = i)
    return(d)
  }



#' Create a lookup table for the subject Predictors
#'
#' @param subject_predictors  a vectore containing the names of the subject predictors
#' @return a dataframe with a lookup table
create_subject_predictor_lookuptable <-
  function(subject_predictors) {
    subject_predictors_index <-
      seq(1:length(subject_predictors)) #sequential indexing starting with 1
    #Now we have a lookup table to convert the indexes
    lookup_table <-
      data.frame(Names = subject_predictors, Index = subject_predictors_index)
    return(as.data.frame(lookup_table))
  }

#' Replace the name of the parameter from index to name using a lookup_table
#' Receives a data frame and returns a dataframe.
#' @param d dataframe
#' @param column name of the colum
#' @param par  name of the parameter
#' @param lookup_table lookup table of the players
#' @param cluster_lookup_table a lookup table of the clusters
#' @param cluster_lookup_table a lookup table of the predictors
#' @param predictors_lookup_table  a lookup table for the predictors
#' @param subject_predictors_lookup_table a lookup table for the subject predictors
#' @return a data. frame where we change the names in the variable colum to the corresponding parameter_name from the lookup table
replace_parameter_index_with_names <-
  function(d,
           column,
           par,
           lookup_table,
           cluster_lookup_table = NULL,
           predictors_lookup_table = NULL,
           subject_predictors_lookup_table = NULL) {
    d <- as.data.frame(d)
    #If not one of the if else parameters we dont change the name
    if (par == 'lambda') {
      for (i in 1:nrow(lookup_table)) {
        old_name <- paste(par, '[', i, ']', sep = "")
        new_name <-
          paste(par, '[', lookup_table$Names[i], ']', sep = "")
        for (j in 1:nrow(d)) {
          d[j, column] <-
            gsub(
              pattern = old_name,
              replacement = new_name,
              x = d[j, column],
              fixed = T
            )#string as is
        }
      }
    }

    else if (par == 'U1')
    {
      for (i in 1:nrow(lookup_table)) {
        for (j in 1:nrow(cluster_lookup_table[[1]])) {
          old_name <- paste(par, '[', i, ',', j, ']', sep = "")
          new_name <-
            paste(par,
                  '[',
                  lookup_table$Names[i],
                  ',',
                  cluster_lookup_table[[1]]$Names[j],
                  ']',
                  sep = "")
          for (k in 1:nrow(d)) {
            d[k, column] <-
              gsub(
                pattern = old_name,
                replacement = new_name,
                x = d[k, column],
                fixed = T
              )#string as is
          }
        }
      }
    }
    else if (par == 'U2')
    {
      for (i in 1:nrow(lookup_table)) {
        for (j in 1:nrow(cluster_lookup_table[[2]])) {
          old_name <- paste(par, '[', i, ',', j, ']', sep = "")
          new_name <-
            paste(par,
                  '[',
                  lookup_table$Names[i],
                  ',',
                  cluster_lookup_table[[2]]$Names[j],
                  ']',
                  sep = "")
          for (k in 1:nrow(d)) {
            d[k, column] <-
              gsub(
                pattern = old_name,
                replacement = new_name,
                x = d[k, column],
                fixed = T
              )#string as is
          }
        }
      }
    }
    else if (par == 'U3')
    {
      for (i in 1:nrow(lookup_table)) {
        for (j in 1:nrow(cluster_lookup_table[[3]])) {
          old_name <- paste(par, '[', i, ',', j, ']', sep = "")
          new_name <-
            paste(par,
                  '[',
                  lookup_table$Names[i],
                  ',',
                  cluster_lookup_table[[3]]$Names[j],
                  ']',
                  sep = "")
          for (k in 1:nrow(d)) {
            d[k, column] <-
              gsub(
                pattern = old_name,
                replacement = new_name,
                x = d[k, column],
                fixed = T
              )#string as is
          }
        }
      }
    }
    else if (par == 'S')
    {
      for (i in 1:nrow(lookup_table)) {
        for (j in 1:nrow(subject_predictors_lookup_table)) {
          old_name <- paste(par, '[', i, ',', j, ']', sep = "")
          new_name <-
            paste(
              par,
              '[',
              lookup_table$Names[i],
              ',',
              subject_predictors_lookup_table$Names[j],
              ']',
              sep = ""
            )
          for (k in 1:nrow(d)) {
            d[k, column] <-
              gsub(
                pattern = old_name,
                replacement = new_name,
                x = d[k, column],
                fixed = T
              )#string as is
          }
        }
      }
    }
    else if (par == 'B')
    {
      for (i in 1:nrow(predictors_lookup_table)) {
        old_name <- paste(par, '[', i, ']', sep = "")
        new_name <-
          paste(par, '[', predictors_lookup_table$Names[i], ']', sep = "")
        for (j in 1:nrow(d)) {
          d[j, column] <-
            gsub(
              pattern = old_name,
              replacement = new_name,
              x = d[j, column],
              fixed = T
            )#string as is
        }
      }
    }

    return(d)
  }

#' Create an array with the parameter name and to what player/cluster it refers to in the order stan presents
#' @param par  name of the parameter
#' @param lookup_table lookup table of the players
#' @param cluster_lookup_table a list of lookup table of the clusters
#' @param subject_predictors_lookup_table a subject predictor lookup table
#' @param keep_par_name keep the parameter name e.g. lambda[Graff] instead of Graff. Default to T. Only valid for lambda, so we can have better ranks
#' @return a data. frame where we change the names in the variable column to the corresponding parameter_name from the lookup table
create_array_of_par_names <-
  function(par,
           lookup_table,
           cluster_lookup_table = NULL,
           subject_predictors_lookup_table = NULL,
           keep_par_name=T) {
    out <- NULL
    if (par == 'lambda') {
        nplayers <- nrow(lookup_table)
        l <- rep('lambda', nplayers)
        sB <- rep('[', nplayers)
        cB <- rep(']', nplayers)
      if(keep_par_name){
        out <- paste(l, sB, lookup_table$Names, cB, sep = "")
      }
      else{
        out <- paste(lookup_table$Names, sep = "")
      }

    }

    else if (par == 'U1')
    {
      if (is.null(cluster_lookup_table))
        stop('A cluster lookup table should be provided')
      cl <- cluster_lookup_table[[1]]
      nplayers <- nrow(lookup_table)
      nclusters <- nrow(cl)
      n <- nplayers * nclusters
      print(n)
      U <- rep('U1', n)
      cluster_nplayer <- rep(cl$Names, each = nplayers)
      players_nclusters <- rep(lookup_table$Names, times = nplayers)
      sB <- rep('[', n)
      cB <- rep(']', n)
      out <-
        paste(U, sB, players_nclusters, ',', cluster_nplayer, cB, sep = "")
    }
    else if (par == 'U2')
    {
      if (is.null(cluster_lookup_table))
        stop('A cluster lookup table should be provided')
      cl <- cluster_lookup_table[[2]]
      nplayers <- nrow(lookup_table)
      nclusters <- nrow(cl)
      n <- nplayers * nclusters
      U <- rep('U2', n)
      cluster_nplayer <- rep(cl$Names, each = nplayers)
      players_nclusters <- rep(lookup_table$Names, times = nplayers)
      sB <- rep('[', n)
      cB <- rep(']', n)
      out <-
        paste(U, sB, players_nclusters, ',', cluster_nplayer, cB, sep = "")
    }
    else if (par == 'U3')
    {
      if (is.null(cluster_lookup_table))
        stop('A cluster lookup table should be provided')
      cl <- cluster_lookup_table[[3]]
      nplayers <- nrow(lookup_table)
      nclusters <- nrow(cl)
      n <- nplayers * nclusters
      U <- rep('U3', n)
      cluster_nplayer <- rep(cl$Names, each = nplayers)
      players_nclusters <- rep(lookup_table$Names, times = nplayers)
      sB <- rep('[', n)
      cB <- rep(']', n)
      out <-
        paste(U, sB, players_nclusters, ',', cluster_nplayer, cB, sep = "")
    }
    else if (par == 'S')
    {
      if (is.null(subject_predictors_lookup_table))
        stop('A subject predictors lookup table  should be provided')
      s <- subject_predictors_lookup_table
      nplayers <- nrow(lookup_table)
      ns <- nrow(s)
      n <- nplayers * ns
      U <- rep('S', n)
      subject_predictors_nplayer <- rep(s$Names, each = nplayers)
      players_nsubjectpredictors <-
        rep(lookup_table$Names, times = nplayers)
      sB <- rep('[', n)
      cB <- rep(']', n)
      out <-
        paste(U,
              sB,
              players_nsubjectpredictors,
              ',',
              subject_predictors_nplayer,
              cB,
              sep = "")
    }
    else{
      out <- par
    }
    return(out)
  }
