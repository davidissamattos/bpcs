#' Bayesian Paired comparison  regression models in Stan
#'
#' This is the main function of the package.
#' This function utilizes precompiled stan models to sample the posterior distribution of the specified model with the input data.
#' For more information and larger examples of usage see the vignettes.
#' @param data A data frame containing the observations. The other parameters specify the name of the columns
#' @param model_type We first add a base model 'bt' or 'davidson' and then additional options with '-'
#' * 'bt' for the Bradley Terry model. Ref: Bradley-Terry 1952,
#' * 'davidson' the Davidson model to handle for ties. Ref: Davidson 1970
#' * 'bt-ordereffect' for the Bradley-Terry with order effect, for home advantage. Ref: Davidson 1977
#' * 'davidson-ordereffect' for the Davidson model with order effect, for home advantage, and ties. Ref: Davidson 1977
#' * 'bt-generalized': for the generalized Bradley Terry model for subject specific predictors. Ref: Springall 1973
#' * 'davidson-generalized' for the generalized Davidson model for subject specific predictors
#' * 'bt-U': for the Bradley-Terry with random effects. Ref: Bockenholt 2001
#' * 'davidson-U': For Davidson model with random effects
#' * 'bt-ordereffect-U' for Bradley-Terry with order effects and random effects, use similar syntax for other variations by appending the correct options
#' @param player0 A string with name of the column containing the players 0. This column should be of string/character type and not be of factor type.
#' @param player1 A string with name of the column containing the players 0. This column should be of string/character type and not be of factor type.
#' @param player0_score A string with name of the column containing the scores of players 0
#' @param player1_score A string with name of the column containing the scores of players 1
#' @param result_column A string with name of the column containing the winners. 0 for player 0, 1 for player 1 and 2 for ties
#' @param z_player1 A string with the name of the column containing the order effect for player 1. E.g. if player1 has the home advantage this column should have 1 otherwise it should have 0
#' @param cluster A string with the name of the column containing the cluster for the observation. To be used with a random effects model. This column should contain strings
#' @param predictors A data frame that contains the players predictors values when using a generalized model. Only numeric values are accepted. Booleans are accepted but will be cast into integers. The first column should be for the player name, the others will be the predictors.  The column names will be used as name for the predictors
#' @param solve_ties A string for the method of handling ties.
#' * 'random' for converting ties randomly,
#' * 'remove' for removing the tie occurrences
#' * 'none' to ignore ties. This requires a model capable of handling  ties
#' @param priors A list with the parameters for the priors.
#' * 'prior_lambda_mu' Mean value of the lambda parameter in the all models. For the generalized this is also the prior for the B the parameter for  lambda ~ normal(mu, std)
#' * 'prior_lambda_std' Standard deviation of the lambda parameter in the all models. lambda ~ normal(mu, std)
#' * 'prior_nu_mu' Mean value of the nu parameter in the Davidson  models. nu ~ normal(mu, std)
#' * 'prior_nu_std' Standard deviation ofnu parameter in the Davidson  models. nu ~ normal(mu, std). Default = 0.3
#' * 'prior_gm_mu' Mean value of the gm in the ordered effect model. gm ~ normal(mu, std). Default = 0
#' * 'prior_gm_std' Standard deviation of the gm parameter in the ordered effect model. gm ~ normal(mu, std). Default =
#' * 'prior_U_std' Standard deviation of the U parameter in the random effects model. U ~ normal(0, std). Default = 3.0
#' @param win_score A string that indicates if which score should win
#' * 'higher' score is winner
#' * 'lower' score is winner
#' @param chains Number of chains passed to Stan sampling. Positive integer, default=4. For more information consult Stan documentation
#' @param iter Number of iterations passed to Stan sampling. Positive integer, default =2000. For more information consult Stan documentation
#' @param warmup Number of iteration for the warmup passed to Stan sampling. Positive integer, default 1000.  For more information consult Stan documentation
#' @param show_chain_messages Hide chain messages from Stan
#' @param seed a random seed for Stan
#' @return An object of the class bpc. This object should be used in conjunction with the several auxiliary functions from the package
#' @export
#' @references
#' 1. Bradley RA, Terry ME 1952. Rank Analysis of Incomplete Block Designs I: The Method of Paired Comparisons. Biometrika, 39, 324 45.
#' 2. Davidson RR 1970. On Extending the Bradley-Terry Model to Accommodate Ties in Paired Comparison Experiments. Journal of the American Statistical Association, 65, 317 328.
#' 3. Davidson, Roger R., and Robert J. Beaver 1977. "n extending the Bradley-Terry model to incorporate within-pair order effects. Biometrics: 693 702.
#' 4. Stan Development Team 2020. RStan: the R interface to Stan. R package version 2.21.2.
#' 5. Bockenholt, Ulf. Hierarchical modeling of paired comparison data. Psychological Methods 6.1 2001: 49.
#' 6. Springall, A. Response Surface Fitting Using a Generalization of the Bradley-Terry Paired Comparison Model. Journal of the Royal Statistical Society: Series C Applied Statistics 22.1 1973: 59 68.
#'
#' @examples
#' \donttest{
#' #For the simple Bradley-Terry model
#' bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' }
bpc <- function(data,
                player0,
                player1,
                player0_score = NULL,
                player1_score = NULL,
                result_column = NULL,
                z_player1 = NULL,
                cluster = NULL,
                predictors = NULL,
                model_type,
                solve_ties = 'random',
                win_score = 'higher',
                priors = NULL,
                chains = 4,
                iter = 2000,
                warmup = 1000,
                show_chain_messages = TRUE,
                seed = NA) {
  if ((is.null(player0_score) |
       is.null(player1_score)) & is.null(result_column))
    stop(
      'Error! It is required to have either scores for both player0 and player1 OR a column indicating who won (0 for player0 1 for player1'
    )

  if (is.data.frame(data) == F & tibble::is_tibble(data) == F)
    stop('Error! Wrong data format. data should be either a data frame or a tibble')

  #checking inputs with the type of model
  if (!is.null(z_player1) &
      !stringr::str_detect(model_type, '-ordereffect'))
    stop(
      'Error! If the order effect column is specified you should choose a model with ordereffect'
    )

  if (!is.null(cluster) &  !stringr::str_detect(model_type, '-U'))
    stop(
      'Error! If the cluster column is specified you should choose a model to handle the random effects of the cluster'
    )

  if (!is.null(predictors) &
      !stringr::str_detect(model_type, '-generalized'))
    stop('Error! If the predictors dataframe is specified you should choose a generalized model')

  if (solve_ties != 'none' &
      startsWith(model_type, 'davidson'))
    warning(
      'You are calling a variation of the Davidson model but you are handling the ties. Consider switching to a Bradley-Terry model'
    )


  call_arg = list(
    data = data,
    player0 = player0,
    player1 = player1,
    player0_score = player0_score,
    player1_score = player1_score,
    result_column = result_column,
    z_player1 = z_player1,
    cluster = cluster,
    predictors = predictors,
    model_type = model_type,
    solve_ties = solve_ties,
    win_score = win_score,
    priors = priors,
    chains = chains,
    iter = iter,
    warmup = warmup,
    seed = seed
  )

  #Show chain messages
  if (show_chain_messages == F) {
    refresh <- 0
  }
  else{
    refresh <- floor(iter / 10)
  }


  #Handling the data and preparing it for the models

  d <- as.data.frame(data)

  ##How to handle NA: at the moment we remove NA from the data frame
  dropna_cols <-
    c(player0,
      player1,
      player0_score,
      player1_score,
      result_column,
      z_player1)
  d <- tidyr::drop_na(d, tidyselect::any_of(dropna_cols))


  ## Create a result column and a tie column from the scores
  ### If we provide only the scores we need to create a winner vector and process the ties
  if (!is.null(player0_score) & !is.null(player1_score))
  {
    #### compute scores already computes the ties and handle it
    d <- compute_scores(d,
                        player0_score,
                        player1_score,
                        solve_ties = solve_ties,
                        win_score = win_score)
  }
  ## If we dont have the scores but the result column we check it and create a ties column
  ### If one of the score vectors is null we need to have the winner vector
  if (is.null(player0_score) | is.null(player1_score))
  {
    d$y <- d[, result_column]
    if (!check_result_column(d$y))
      stop('Error! Wrong format for the result column')
    d <- compute_ties(d, result_column)
  }

  #Further checks before we call the model with stan

  # Check if everything is in order with solve_ties and the choice of model
  ## if there are ties we should not use any of the BT models
  ties_present <- check_if_there_are_ties(d$y)
  if (solve_ties == 'none' &
      !stringr::str_detect(model_type, 'davidson') &
      ties_present == T)
    stop('Error! If not handling the ties a version of Davidson model should be used')

  # check the z column
  if (!is.null(z_player1))
    if (!check_z_column(d[, z_player1]))
      stop('z_player1 column is not well specified. It should only contain 0 and 1')

  # For our stan model we need the index for the players not the actual name
  d <- create_index(d, player0, player1)
  lookup_table <- create_index_lookuptable(d, player0, player1)


  # Handling clusters if available
  cluster_lookup_table <- NULL
  if (!is.null(cluster))
  {
    d <- create_cluster_index(d, cluster)
    cluster_lookup_table <-
      create_index_cluster_lookuptable(d, cluster)
  }
  else{
    cluster_lookup_table <- NULL
  }

  #Handling predictors in the generalized model if available
  predictors_lookup_table <- NULL
  predictors_matrix <- NULL
  predictors_df <- NULL
  if (!is.null(predictors)) {
    if (!check_predictors_df_contains_all_players(predictors, lookup_table))
      stop(
        'The predictor matrix is mispecified. It should contain all the players from the data frame and only them'
      )

    predictor_all_columns <- colnames(predictors)
    predictors_columns <-
      predictor_all_columns[2:length(predictor_all_columns)]
    player_column <- predictor_all_columns[1]
    predictors_matrix <-
      create_predictor_matrix_with_player_lookup_table(
        d = predictors,
        player =
          player_column,
        predictors_columns =
          predictors_columns,
        lookup_table =
          lookup_table
      )
    predictors_lookup_table <-
      create_predictors_lookup_table(predictors_columns)
    if (!check_numeric_predictor_matrix(predictors_matrix))
      stop(
        'The predictors are mispecified. Only numeric values are accepted. Booleans are accepted but will be cast into integers'
      )
    predictors_df <- predictors
  }
  else{
    predictors_lookup_table <- NULL
    predictors_matrix <- NULL
    predictors_df <- NULL
  }



  # Setting the priors
  default_std <- 3.0
  default_mu <- 0.0

  ##Lambda
  if (is.null(priors$prior_lambda_std))
    prior_lambda_std <- default_std
  else
    prior_lambda_std <- priors$prior_lambda_std
  if (is.null(priors$prior_lambda_mu))
    prior_lambda_mu <- default_mu
  else
    prior_lambda_mu <- priors$prior_lambda_mu
  ## Nu
  if (is.null(priors$prior_nu_std))
    prior_nu_std <- default_std / 10 # default is 0.3
  else
    prior_nu_std <- priors$prior_nu_std
  if (is.null(priors$prior_nu_mu))
    prior_nu_mu <- default_mu
  else
    prior_nu_mu <- priors$prior_nu_mu
  ##GM
  if (is.null(priors$prior_gm_mu))
    prior_gm_mu <- default_mu
  else
    prior_gm_mu <- priors$prior_gm_mu
  if (is.null(priors$prior_gm_std))
    prior_gm_std <- default_std / 3.0 #default is 1
  else
    prior_gm_std <- priors$prior_gm_std
  ##U
  if (is.null(priors$prior_U_std))
    prior_U_std <- default_std
  else
    prior_U_std <- priors$prior_U_std

  #Base standata
  standata <- list(
    y = as.vector(d$y),
    ties = as.vector(d$ties),
    N_total = nrow(d),
    N_players = nrow(lookup_table),
    player0_indexes = as.vector(d$player0_index),
    player1_indexes = as.vector(d$player1_index),
    prior_lambda_mu = prior_lambda_mu,
    prior_lambda_std = prior_lambda_std,
    prior_gm_mu = prior_gm_mu,
    prior_gm_std = prior_gm_std,
    prior_nu_mu = prior_nu_mu,
    prior_nu_std = prior_nu_std
  )
  stanfit <- NULL

  # Add order effect or not
  if (stringr::str_detect(model_type, '-ordereffect')) {
    standata <- c(standata, list(use_Ordereffect = 1,
                                 z_player1 = as.vector(d[, z_player1])))
  } else{
    standata <- c(standata, list(use_Ordereffect = 0,
                                 z_player1 = numeric(0)))
  }

  # Add random effects or not
  if (stringr::str_detect(model_type, '-U')) {
    standata <- c(standata,
                  list(
                    use_U = 1,
                    N_U = nrow(cluster_lookup_table),
                    z_player1 = as.vector(d[, z_player1]),
                    U_indexes = as.vector(d$cluster_index)
                  ))
  } else{
    standata <- c(standata,
                  list(
                    use_U = 0,
                    N_U = 0,
                    z_player1 = numeric(0),
                    U_indexes = numeric(0)
                  ))
  }

  # Generalized or not
  if (stringr::str_detect(model_type, '-generalized')) {
    standata <- c(standata,
                  list(
                    use_Generalized = 1,
                    K = nrow(predictors_lookup_table),
                    X = predictors_matrix
                  ))
  } else{
    standata <- c(standata,
                  list(
                    use_Generalized = 0,
                    K = 0,
                    X = matrix(NA_real_, ncol = 0,nrow = 0)
                  ))
  }

  # Davidson or not
  if (startsWith(model_type, 'davidson')) {
    standata <- c(standata,
                  list(use_Davidson = 1))
  } else{
    standata <- c(standata,
                  list(use_Davidson = 0))
  }



  # Now we do the sampling in Stan
  if (startsWith(model_type, 'bt') |
      startsWith(model_type, 'davidson')) {
    stanfit <-
      rstan::sampling(
        stanmodels$bt,
        data = standata,
        chains = chains,
        iter = iter,
        warmup = warmup,
        refresh = refresh,
        seed = seed
      )
  } else
    stop("Invalid model type")


  #Defining a bpc object

  out <- create_bpc_object(
    stanfit,
    lookup_table,
    model_type,
    standata,
    call_arg,
    cluster_lookup_table = cluster_lookup_table,
    predictors_df = predictors_df,
    predictors_lookup_table = predictors_lookup_table,
    predictors_matrix = predictors_matrix
  )
  return(out)

}
