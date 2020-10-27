#' Create a lookup table of names and indexes
#' Note that the indexes will be created in the order they appear. For string this doesnt make much difference but for numbers the index might be different than the actual number that appears in names
#' @param d A data frame containing the observations. The other parameters specify the name of the columns
#' @param player0 The name of the column of data  contains player0
#' @param player1 The name of the column of data  contains player0
#'
#' @return A dataframe of a lookup table with columns Names and Index
create_index_lookuptable <-function(d,player0,player1){
  d<-as.data.frame(d)
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
#' @param d A data frame containing the observations. The other parameters specify the name of the columns
#' @param player0 The name of the column of data data contains player0
#' @param player1 The name of the column of data data contains player0
#'
#' @return A dataframe with the additional columns 'player0_index' and 'player1_index' that contains the indexes

create_index <- function(d, player0, player1){
  d<-as.data.frame(d)

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



#' Returns the lower value of the HPD interval for a data frame column
#' @references
#' Mike Meredith and John Kruschke (2020). HDInterval: Highest (Posterior) Density Intervals. R package version 0.2.2. https://CRAN.R-project.org/package=HDInterval
#' @param column the data to calculate the HPDI
#' @param credMass Credibility mass for the interval (area contained in the interval)
#' @return the value of the lower HPD interval for that column
HPD_lower_from_column<-function(column, credMass=0.95){
  hdi_col<-HDInterval::hdi(column, credMass=credMass)
  return(hdi_col[[1]])
}

#' Returns the higher value of the HPD interval for a data frame column
#' @references
#' Mike Meredith and John Kruschke (2020). HDInterval: Highest (Posterior) Density Intervals. R package version 0.2.2. https://CRAN.R-project.org/package=HDInterval
#' @param column the data to calculate the HPDI
#' @param credMass Credibility mass for the interval (area contained in the interval)
#' @return the value of the higher HPD interval for that column
HPD_higher_from_column<-function(column, credMass=0.95){
  hdi_col<-HDInterval::hdi(column, credMass=credMass)
  return(hdi_col[[2]])
}


#' Calculate HPDI for all parameters from a stanfit object
#' Here we use the coda package
#' @references Martyn Plummer, Nicky Best, Kate Cowles and Karen Vines (2006). CODA: Convergence Diagnosis and Output Analysis for MCMC, R News, vol 6, 7-11
#' @param stanfit a stanfit object retrived from a bpc object
#' @return a data frame with the HPDI calculated from the coda pacakge
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
#' Here we select a parameter, retrieve the all the posterior from the stanfit and then we resample this posterior n times
#' @references Stan Development Team (2020). RStan: the R interface to Stan. R package version 2.21.2. http://mc-stan.org/.
#' @param stanfit stanfit object
#' @param par parameter name
#' @param n number of samples
#' @return a dataframe containing the samples of the parameter. Each column is a parameter (in order of the index), each row is a sample
sample_stanfit<-function(stanfit,par,n=100){
  posterior <- rstan::extract(stanfit)
  posterior<- as.data.frame(posterior[[par]])
  #re sampling from the posterior
  s <- dplyr::sample_n(posterior, size = n, replace=T)
  return(as.data.frame(s))
}


#' Giving a player0 an player1 scores, this functions adds one column to the data frame containing who won (0= player0 1=player1 2=tie) and another if it was a tie.
#' The ties column superseeds the y column.
#' If it was tie the y column does not matter
#' y column: (0= player0 1=player1 2=tie)
#' ties column (0=not tie, 1=tie)
#' @param d dataframe
#' @param player0_score name of the column in data
#' @param player1_score name of the column in data
#' @param solve_ties Method to solve the ties, either randomly allocate, or do nothing, or remove the row from the datasetc('random', 'none', 'remove').
#' @param win_score decides if who wins is the one that has the highest score or the lowest score
#' @return a dataframe with column 'y' that contains the results of the comparison and a ties column indicating if there was ties
compute_scores<-function(d,
                         player0_score,
                         player1_score,
                         solve_ties='random',
                         win_score='higher'){
  d<-as.data.frame(d)


  d$diff_score<- as.vector(d[,player1_score]-d[,player0_score])
  # If higher score better than lower score for winning
  if(win_score=='higher')
  {
    player1win<-ifelse(d$diff_score >0, 1,
                       ifelse(d$diff_score <0, 0, 2))
    d$y<- as.vector(player1win)
  }
  else #lower
  {
    player1win<-ifelse(d$diff_score <0, 1,
                       ifelse(d$diff_score >0, 0, 2))
    d$y<- as.vector(player1win)
  }

  # How to handle ties in the scores
  if(solve_ties=='none')
  {

  }
  if(solve_ties=='random')
  {
    for(i in 1:nrow(d)){
      if(d$y[i]==2)
        d$y[i]= sample(c(0,1), replace=T, size=1)
    }

  }
  if(solve_ties=='remove')
  {
    d$ties<-ifelse(d$diff_score!=0,0,NA)
    d<-tidyr::drop_na(d,tidyselect::any_of('ties'))
    d<-dplyr::select(d, -ties)
  }

  d<-compute_ties(d,'y')
  d<-dplyr::select(d, -diff_score)
  return(as.data.frame(d))
}

#' Giving a result column we create a new column with ties (0 and 1 if it has)
#' @param d data frame
#' @param result_column column where the result is
#' @return dataframe with a column called ties
compute_ties<-function(d, result_column){
  d<-as.data.frame(d)
  if(check_result_column(d[,result_column])){
    d$ties<-ifelse(d[,result_column] ==2, 1,0)
    return(as.data.frame(d))
  }
  else
    stop('compute_ties: Result column in the wrong format')

}

#' Check if a data frame column contains only the values 1 0 and 2. Used to check the format of the results
#' @param d_column
#'
#' @return TRUE (correct) or FALSE (with problems)
check_result_column<-function(d_column){
  passed<- all(d_column %in% c(2,0,1))
  return(passed)
}

#' Check if a data frame column contains ties
#' @param d_column a column with the values for the ties
#' @return T (there are ties) or F (no ties)
check_if_there_are_ties<-function(d_column){
  ties<- any(d_column %in% c(2))
  return(ties)
}


#' Check for NA in the specfic columns and returns T or F is there is at least 1 NA in those columns
#'
#' @param d a data frame
#' @param player0 the name of column for player0
#' @param player1 the name of column for player1
#' @param player0_score the name of column for player0 scores
#' @param player1_score the name of column for player1 scores
#' @param result_column the name of column for results
#' @return TRUE (there are NA) or FALSE (no NA)
check_if_there_are_na<-function(d, player0,player1,player0_score,player1_score,result_column)
{
  d<-as.data.frame(d)
  na_cols<-c(player0,player1,player0_score,player1_score,result_column)
  for(col in na_cols){
    check_na<-any(is.na(d[,col]))
    if(check_na==T)
      return(T)
  }
  return(F)
}


#' Return all the name of parameters in a model from a bpc_object.
#' Here we exclude the log_lik and the lp__ since they are not parameters of the model
#' @param bpc_object a bpc object
#' @return a vector with the name of the parameters
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
#' E.g  for parameter lambda with 4 players we have (lambda[1], lambda[2], lambda[3], lambda[4]). This function will return (lambda_Biometrika, lambda_CommStat, lambda_JASA, lambda_JRSSB)
#' @param d dataframe
#' @param column name of the colum
#' @param par  name of the parameter
#' @param lookup_table a data frame
#' @return a data. frame where we change the names in the variable colum to the corresponding parameter_name from the lookup table
replace_parameter_index_with_names<-function(d,column,par,lookup_table){
  d<-as.data.frame(d)
  for(i in 1:nrow(lookup_table)){
    old_name<-paste(par,'[',i,']',sep="")
    new_name<-paste(par,'_',lookup_table$Names[i],sep="")
    for(j in 1:nrow(d)){
      d[j,column]<-gsub(pattern=old_name,replacement=new_name,x=d[j,column],fixed = T)#string as is
    }
  }
  return(d)
}

#' Helper function for the get_par_names function in exports. This creates an array with the name of the parameter and the corresponding index
#' @param par a name for the parameter
#' @param lookup_table a lookuptable to convert the indexes to that
#' @return a vector
create_array_of_par_names <- function(par,lookup_table){
  name<-rep(paste(par,'_',sep = ""), nrow(lookup_table))
  name<-paste(name,lookup_table$Names,sep="")
  return(name)
}
