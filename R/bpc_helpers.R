#' Create a lookup table of names and indexes
#' Note that the indexes will be created in the order they appear. For string this doesnt make much difference but for numbers the index might be different than the actual number that appears in names
#' @param data A data frame containing the observations. The other parameters specify the name of the columns
#' @param player0 The name of the column of data data contains player0
#' @param player1 The name of the column of data data contains player0
#'
#' @return A dataframe of a lookup table with columns Names and Index
create_index_lookuptable <-function(data,player0,player1){
  d<-as.data.frame(data)
  p0_names <- unique(d[,player0])
  p1_names <- unique(d[,player1])
  player_names <- unique(c(p0_names,p1_names))
  player_index <- seq(1:length(player_names)) #sequential indexing starting with 1

  #Now we have a lookup table to convert the indexes
  lookup_table <- data.frame(Names=player_names, Index=player_index)
  return(as.data.frame(lookup_table))
}

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
  return(as.data.frame(d))
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
#' @param stanfit a stanfit object retrived from a bpc object
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
  return(as.data.frame(df_hpdi))
}

#' Return a data frame by resampling the posterior from a stanfit
#'
#' @param stanfit stanfit object
#' @param par parameter name
#' @param n number of samples
#'
#' @return a dataframe containing the samples of the parameter. Each column is a parameter (in order of the index), each row is a sample

sample_stanfit<-function(stanfit,par,n=100){
  posterior <- rstan::extract(stanfit)
  posterior<- as.data.frame(posterior[[par]])
  #re sampling from the posterior
  s <- dplyr::sample_n(posterior, size = n, replace=T)
  return(as.data.frame(s))
}


#' Giving a player0 an player1 it adds a column to the data frame containing who won or if it was a tie
#'
#' @param data dataframe
#' @param player0_score name of the column in data
#' @param player1_score name of the column in data
#' @param solve_ties Method to solve the ties, either randomly allocate, or do nothing, or remove the row from the datasetc('random', 'none', 'remove').
#' @param win_score decides if who wins is the one that has the highest score or the lowest score
#'
#' @return a dataframe with column 'y' that contains the results of the comparison
#'
#' @examples
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
    d$y<- as.vector(player1win+tie)
  }

  # How to handle ties in the scores
  if(solve_ties=='none')
  {
    #we dont need to do anything
  }
  if(solve_ties=='random')
  {
    for(i in 1:nrow(d)){
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
  return(as.data.frame(d))
}

#' Check if a data frame column contains only the values 1 0 and -1
#'
#' @param d_column
#'
#' @return T (correct) or F (with problems)
check_result_column<-function(d_column){
  passed<- all(d_column %in% c(-1,0,1))
  return(passed)
}

#' Check if a data frame column contains ties:-1
#'
#' @param d_column
#'
#' @return T (there are ties) or F (no ties)
check_if_there_are_ties<-function(d_column){
  ties<- any(d_column %in% c(-1))
  return(ties)
}


#' Check for NA in the specfic columns and returns T or F is there is at least 1 NA in those columns
#'
#' @param d
#' @param player0
#' @param player1
#' @param player0_score
#' @param player1_score
#' @param result_column
#'
#' @return T (there are NA) or F (no NA)
check_if_there_are_na<-function(d, player0,player1,player0_score,player1_score,result_column)
{
  na_cols<-c(player0,player1,player0_score,player1_score,result_column)
  for(col in na_cols){
    check_na<-any(is.na(d[,col]))
    if(check_na==T)
      return(T)
  }
  return(F)
}


get_model_parameters<-function(bpc_object){
  if(class(bpc_object)!='bpc')
    stop('Error! The object is not of bpc class')
  stanfit<-get_stanfit(bpc_object)
  pars_all<-stanfit@model_pars
  pars<- subset(pars_all, !(pars_all %in% c('log_lik','lp__')))
  return(pars)
}

#' Replace the name of the parameter from index to name using a lookup_table
#' Receives a data frame and returns a dataframe
#' lambda[1] --> lambda_Biometrika
#' @param data dataframe
#' @param column name of the colum
#' @param par  name of the parameter
#' @param lookup_table a data frame
#'
#' @return
#'
#' @examples
replace_parameter_index_with_names<-function(data,column,par,lookup_table){
  for(i in 1:nrow(lookup_table)){
    old_name<-paste(par,'[',i,']',sep="")
    new_name<-paste(par,'_',lookup_table$Names[i],sep="")
    for(j in 1:nrow(data)){
      data[j,column]<-gsub(pattern=old_name,replacement=new_name,x=data[j,column],fixed = T)#string as is
    }
  }
  return(data)
}

#' Create an array with the name of the parameter and the corresponding index
#' lambda[1] --> lambda_Biometrika
#'
#' @param par a name for the parameter
#' @param lookup_table a lookuptable to convert the indexes to that
#'
#' @return a vector
#'
#' @examples
create_array_of_par_names <- function(par,lookup_table){
  name<-rep(paste(par,'_',sep = ""), nrow(lookup_table))
  name<-paste(name,lookup_table$Names,sep="")
  return(name)
}
