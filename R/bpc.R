#' Bayesian Paired comparison  regression models in Stan
#'
#' @param data A data frame containing the observations. The other parameters specify the name of the columns
#' @param model_type 'bradleyterry' (default), 'davidson' for ties
#' @param player0 A string with name of the column containing the players 0
#' @param player1 A string with name of the column containing the players 0
#' @param player0_score A string with name of the column containing the scores of players 0
#' @param player1_score A string with name of the column containing the scores of players 1
#' @param result_column A string with name of the column containing the winners. 0 for player 0, 1 for player 1 and -1 for ties
#' @param solve_ties A string for the method of handling ties. 'random' for converting ties randomly, 'remove' for removing the tie occurrencess
#' 'none' to ignore ties. The last requires a model to handle ties such as the davidson
#' @param prior_lambda_std Positive value for the standard deviation of the normal prior if not uniform. Default is 2
#' @param win_score A string that indicates if a 'higher' score is winner or if a 'lower' score is winner
#' @param chains Number of chains passed to Stan sampling. Positive integer, default=4. For more information consult Stan
#' @param iter Number of iterations passed to Stan sampling. Positive integer, default =2000. For more information consult Stan
#' @param warmup Number of iteration for the warmup passed to Stan sampling. Positive integer, default 1000.  For more information consult Stan
#'
#'
#' @return An object of the class TODO:finish
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
                prior_lambda_std=2.0,
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
                  prior_lambda_std=prior_lambda_std,
                  chains=chains,
                  iter=iter,
                  warmup=warmup)

  d <- data

  #Clean NA
  dropna_cols<-c(player0,player1,player0_score,player1_score,result_column)
  d<-tidyr::drop_na(d,tidyselect::any_of(dropna_cols))
  standata=list()

  #Show chain messages
  if(show_chain_messages==F){
    refresh<-0
  }
  else{
    refresh<-1
  }




  # If we provide only the scores we need to create a winner vector and process the ties
  if(!is.null(player0_score) & !is.null(player1_score))
  {
    d<- compute_scores(d,player0_score,
                       player1_score,
                       solve_ties=solve_ties,
                       win_score=win_score)
    standata<-c(standata, y=list(d$y))
  }

  # If one of the score vectors is null we need to have the winner vector
  if(is.null(player0_score) | is.null(player1_score))
  {
    d$y<-d[,result_column]
    standata<-c(standata, y=list(d$y))
  }

  #Check if everything is in order with solve_ties and the choice of model
  ties_present<- check_if_there_are_ties(d$y)
  if(solve_ties=='none' & model_type!='davidson' & ties_present==T)
    stop('Error! If not handling the ties the Davidson model should be used')

  #For our stan model we need the index for the players not the actual name
  d<-create_index(d,player0,player1)
  lookup_table <- create_index_lookuptable(d,player0,player1)

  standata<-c(standata,
              N_total = nrow(d),
              N_players=list(nrow(lookup_table)),
              player0_indexes=list(as.vector(d$player0_index)),
              player1_indexes=list(as.vector(d$player1_index)),
              prior_lambda_std=prior_lambda_std)

  if(model_type=='davidson'){
    # stanfit <- rstan::sampling(stanmodels$davidson, data = standata, chains=chains, iter=iter, warmup=warmup)

  }
  if(model_type=='bradleyterry'){
    stanfit <- rstan::sampling(stanmodels$bt, data = standata, chains=chains, iter=iter, warmup=warmup, refresh=refresh)

  }
  else
    stop("Invalid model type")


  #Defining a bpc object
  out<-create_bpc_object(stanfit, lookup_table, model_type=model_type, standata=standata, call_arg=call_arg)
  return(out)
}
