#' Create two columns with the indexes for the names
#'
#' @param data A data frame containing the observations. The other parameters specify the name of the columns
#' @param player0 The name of the column of data data contains player0
#' @param player1 The name of the column of data data contains player0
#'
#' @return A dataframe with the additional columns 'player0_index' and 'player1_index' that contains the indexes

create_index <- function(data, player0, player1){
  d<-as.data.frame(data)

  #Now we have a lookup table to convert the indexes
  lookup_table <- create_index_lookuptable(d, player0, player1)
  #https://stackoverflow.com/questions/35636315/replace-values-in-a-dataframe-based-on-lookup-table
  player0_index<-lookup_table$Index[match(unlist(d[,player0]), lookup_table$Names)]
  player1_index<-lookup_table$Index[match(unlist(d[,player1]), lookup_table$Names)]

  d$player0_index<-player0_index
  d$player1_index<-player1_index
  #We return a data frame with the indexes
  return(d)
}

#' Create a lookup table of names and indexes
#'
#' @param data A data frame containing the observations. The other parameters specify the name of the columns
#' @param player0 The name of the column of data data contains player0
#' @param player1 The name of the column of data data contains player0
#'
#' @return A dataframe of a lookup table
create_index_lookuptable <-function(data,player0,player1){
  d<-as.data.frame(data)
  p0_names <- unique(d[,player0])
  p1_names <- unique(d[,player1])
  player_names <- unique(c(p0_names,p1_names))
  player_index <- seq(1:length(player_names)) #sequential indexing starting with 1

  #Now we have a lookup table to convert the indexes
  lookup_table <- data.frame(Names=player_names, Index=player_index)
  return(lookup_table)
}

HPD_lower_from_column<-function(column, credMass=0.95){
  hdi_col<-HDInterval::hdi(column, credMass=credMass)
  return(hdi_col[[1]])
}


HPD_higher_from_column<-function(column, credMass=0.95){
  hdi_col<-HDInterval::hdi(column, credMass=credMass)
  return(hdi_col[[2]])
}


#' Calculate HPDI from a stanfit model
#'
#' @param stanfit a stanfit object
#'
#' @return a data frame with the HPDI calculated from coda
HPDI_from_stanfit<- function(stanfit)
{
  hpdi<-coda::HPDinterval(coda::as.mcmc(as.data.frame(stanfit)))
  summary_stan<-rstan::summary(stanfit)
  mean_estimate<-as.data.frame(summary_stan$summary)$mean
  df<-tibble::rownames_to_column(as.data.frame(hpdi), "Parameter")
  df_hpdi<-dplyr::mutate(df,Mean=mean_estimate)
  df_hpdi<-dplyr::rename(df_hpdi,HPD_lower=lower, HPD_higher=upper)
  df_hpdi<-dplyr::select(df_hpdi,Parameter, Mean, HPD_lower, HPD_higher)
  return(df_hpdi)
}

sample_stanfit<-function(stanfit,par,n=100){
  posterior <- rstan::extract(stanfit)
  posterior<- dplyr::as_tibble(posterior[[par]])
  #re sampling from the posterior
  s <- dplyr::sample_n(posterior, size = n, replace=T)
  return(s)
}


compute_scores<-function(data,
                         player0_score,
                         player1_score,
                         solve_ties='random',
                         win_score='higher'){
  d<-data

  d$diff_score<- as.vector(d[,player1_score]-d[,player0_score])
  # If higher score better than lower score for winning
  if(win_score=='higher')
  {
    player1win<-ifelse(d$diff_score >0,1,0)
    tie<-ifelse(d$diff_score==0,-1,0)

    d$y<- as.vector(player1win+tie)
  }
  else #lower
  {
    player1win<-ifelse(d$diff_score <0, 1,0)
    tie<-ifelse(d$diff_score==0,-1,0)
    d$y<- as.vector(ifelse(d$diff_score >0, 0, 1))
  }

  # How to handle ties in the scores
  if(solve_ties=='none')
  {
    #we dont need to do anything
  }
  if(solve_ties=='random')
  {
    for(i in nrow(d)){
      if(d$y[i]==-1)
        d$y[i]= sample(c(0,1), replace=T, size=1)
    }
  }
  if(solve_ties=='remove')
  {
    d$ties<-ifelse(d$diff_score!=0,0,NA)
    d<-tidyr::drop_na(d,tidyselect::any_of('ties'))
    d<-dplyr::select(d, -ties)
  }

  d<-dplyr::select(d, -diff_score)
  return(d)
}

