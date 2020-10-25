#' Bayesian Paired comparison  regression models in Stan
#' This is the main function of the package and it samples the posterior distribution of different models using Stan depending on the parameters choice
#' @param data A data frame containing the observations. The other parameters specify the name of the columns
#' @param model_type 'bradleyterry' (default), 'davidson' for ties
#' @param player0 A string with name of the column containing the players 0
#' @param player1 A string with name of the column containing the players 0
#' @param player0_score A string with name of the column containing the scores of players 0
#' @param player1_score A string with name of the column containing the scores of players 1
#' @param result_column A string with name of the column containing the winners. 0 for player 0, 1 for player 1 and 2 for ties
#' @param solve_ties A string for the method of handling ties. 'random' for converting ties randomly, 'remove' for removing the tie occurrencess
#' 'none' to ignore ties. The last requires a model to handle ties such as the davidson if there are ties
#' @param priors A list with the parameters for the priors. Possible values ''
#' @param win_score A string that indicates if a 'higher' score is winner or if a 'lower' score is winner
#' @param chains Number of chains passed to Stan sampling. Positive integer, default=4. For more information consult Stan
#' @param iter Number of iterations passed to Stan sampling. Positive integer, default =2000. For more information consult Stan
#' @param warmup Number of iteration for the warmup passed to Stan sampling. Positive integer, default 1000.  For more information consult Stan
#' @param show_chain_messages Hide chain messages from stan
#'
#' @return An object of the class bpc. This object should be used in conjunction with the several auxiliary functions from the package
#' @export
#
#' @examples
#'  bpc(data=citations_agresti,
#'               player0 = 'journal1',
#'               player1 = 'journal2',
#'               player0_score = 'score1',
#'               player1_score = 'score2',
#'               model_type='bradleyterry',
#'               solve_ties='random',
#'               win_score = 'higher')
bpc <- function(data,
                player0,
                player1,
                player0_score=NULL,
                player1_score=NULL,
                result_column=NULL,
                model_type='bradleyterry',
                solve_ties='random',
                win_score='higher',
                priors=NULL,
                chains=4,
                iter=2000,
                warmup=1000,
                show_chain_messages=T){

  if((is.null(player0_score) | is.null(player1_score)) & is.null(result_column))
    stop('Error! It is required to have either scores for both player0 and player1 OR a column indicating who won (0 for player0 1 for player1')
  if(is.data.frame(data)==F & tibble::is_tibble(data)==F)
    stop('Error! Wrong data format')

  call_arg = list(data=data,
                  player0=player0,
                  player1=player1,
                  player0_score=player0_score,
                  player1_score=player1_score,
                  result_column=result_column,
                  model_type=model_type,
                  solve_ties=solve_ties,
                  win_score=win_score,
                  priors=priors,
                  chains=chains,
                  iter=iter,
                  warmup=warmup)

  d <- as.data.frame(data)

  #Clean NA
  dropna_cols<-c(player0,player1,player0_score,player1_score,result_column)
  d<-tidyr::drop_na(d,tidyselect::any_of(dropna_cols))

  #Show chain messages
  if(show_chain_messages==F){
    refresh<-0
  }
  else{
    refresh<-floor(iter/10)
  }




  # If we provide only the scores we need to create a winner vector and process the ties
  if(!is.null(player0_score) & !is.null(player1_score))
  {
    d<- compute_scores(d,player0_score,
                       player1_score,
                       solve_ties=solve_ties,
                       win_score=win_score)
  }

  # If one of the score vectors is null we need to have the winner vector
  if(is.null(player0_score) | is.null(player1_score))
  {
    d$y<-d[,result_column]
    if(!check_result_column(d$y))
      stop('Error! Wrong format for the result column')

    d<-compute_ties(d,result_column)
  }

  #Check if everything is in order with solve_ties and the choice of model
  ties_present<- check_if_there_are_ties(d$y)
  if(solve_ties=='none' & model_type!='davidson' & ties_present==T)
    stop('Error! If not handling the ties the Davidson model should be used')

  #For our stan model we need the index for the players not the actual name
  d<-create_index(d,player0,player1)
  lookup_table <- create_index_lookuptable(d,player0,player1)

  #Setting the priors
  if(is.null(priors$prior_lambda_std))
    prior_lambda_std<-3.0
  else
    prior_lambda_std<-priors$prior_lambda_std

  if(is.null(priors$prior_lambda_mu))
    prior_lambda_mu<-10.0
  else
    prior_lambda_mu<-priors$prior_lambda_mu

  if(is.null(priors$prior_nu))
    prior_nu<-0.1
  else
    prior_nu<-priors$prior_nu


  if(model_type=='davidson'){
    standata<- list(
      y=as.vector(d$y),
      N_total = nrow(d),
      N_players=nrow(lookup_table),
      player0_indexes=as.vector(d$player0_index),
      player1_indexes=as.vector(d$player1_index),
      ties=as.vector(d$ties),
      prior_nu=prior_nu,
      prior_lambda_mu=prior_lambda_mu,
      prior_lambda_std=prior_lambda_std
    )
    stanfit <- rstan::sampling(stanmodels$davidson, data = standata, chains=chains, iter=iter, warmup=warmup,refresh=refresh)
  }
  else if(model_type=='bradleyterry'){
    standata<- list(
      y=as.vector(d$y),
      N_total = nrow(d),
      N_players=nrow(lookup_table),
      player0_indexes=as.vector(d$player0_index),
      player1_indexes=as.vector(d$player1_index),
      prior_lambda_mu=prior_lambda_mu,
      prior_lambda_std=prior_lambda_std
    )
    stanfit <- rstan::sampling(stanmodels$bt, data = standata, chains=chains, iter=iter, warmup=warmup, refresh=refresh)

  }
  else
    stop("Invalid model type")


  #Defining a bpc object
  out<-create_bpc_object(stanfit, lookup_table, model_type=model_type, standata=standata, call_arg=call_arg)
  return(out)
}
