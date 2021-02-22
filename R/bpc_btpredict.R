#' This function emulates the generate quantities from stan that is not working in some cases
#' @param standata a list  containing the data from stan
#' @param draws a matrix of draws from the parameters of the sampled model
#' @return a matrix with each column represents a posterior prediction of the data and each row a predicted value
btpredict <- function(standata, draws){
  N_total <-standata$N_newdata
  n <- nrow(draws)
  y_pred<-matrix(data=NA,nrow=n,ncol = N_total)
  parameters <- list(
    lambda = draws[,startsWith(colnames(draws), 'lambda[')],
    gm = draws[,'gm'],
    nu = draws[,'nu'],
    U1_std = draws[,'U1_std'],
    U1 = draws[,startsWith(colnames(draws), 'U1[')],
    U2_std = draws[,'U2_std'],
    U2 = draws[,startsWith(colnames(draws), 'U2[')],
    U3_std = draws[,'U3_std'],
    U3 = draws[,startsWith(colnames(draws), 'U3[')],
    B = draws[,startsWith(colnames(draws), 'B[')],
    S = draws[,startsWith(colnames(draws), 'S[')]
    )


  for (i in seq(1,N_total)){
    prob <- calculate_p1_win_and_ties(i,standata, parameters, n);
    p1_win <- prob$p1_win
    p_tie <- prob$p_tie
    ties_pred = bernoulli_rng(n, p_tie)
    win <-  bernoulli_rng(n, p1_win)
    y_pred[,i] <- ifelse(ties_pred==1,2,win)
  }

  colnames(y_pred) <- paste(
    rep('y_pred[',N_total),
    seq(1:N_total),
    rep(']',N_total),
    sep=""
  )
  return(y_pred)
}

#' Calcutate the probability for a single row
#' @param i row number
#' @param standata input standata
#' @param parameters input sampled parameters
#' @param n number of draws
#' @return an array with probability of win1 and probability of tie
calculate_p1_win_and_ties <- function(i,standata,parameters,n){
  z<-NULL
  U01 <- NULL
  U11 <- NULL
  U02 <- NULL
  U12 <- NULL
  U03 <- NULL
  U13 <- NULL
  player1_indexes <- standata$player1_indexes
  player0_indexes <- standata$player0_indexes
  U1_indexes<- standata$U1_indexes
  U2_indexes<- standata$U2_indexes
  U3_indexes<- standata$U3_indexes
  X_subject <- standata$X_subject
  S0 <- NULL
  S1 <- NULL
  N_players <- standata$N_players



  if(standata$use_Ordereffect){
    z <- standata$z_player1[i]
  }else{
    z <- standata$N_newdata[i]
  }


  if(standata$use_U1){
    index1<- paste('U1[',player1_indexes[i],',',U1_indexes[i],']',sep = "")
    index0<- paste('U1[',player0_indexes[i],',',U1_indexes[i],']',sep = "")
    U01<-parameters$U1[, index0]
    U11<-parameters$U1[, index1]
  }else{
    U01<-0
    U11<-0
  }

  if(standata$use_U2){
    index1<- paste('U2[',player1_indexes[i],',',U2_indexes[i],']',sep = "")
    index0<- paste('U2[',player0_indexes[i],',',U2_indexes[i],']',sep = "")
    U02<-parameters$U2[, index0]
    U12<-parameters$U2[, index1]
  }else{
    U02<-0
    U12<-0
  }

  if(standata$use_U3){
    index1<- paste('U3[',player1_indexes[i],',',U3_indexes[i],']',sep = "")
    index0<- paste('U3[',player0_indexes[i],',',U3_indexes[i],']',sep = "")
    U03<-parameters$U3[, index0]
    U13<-parameters$U3[, index1]
  }else{
    U03<-0
    U13<-0
  }




  # dot product in R %*%
  if(standata$use_SubjectPredictors){
    #subsetting
    S_p1 <- parameters$S[,startsWith(colnames(parameters$S),paste('S[',player1_indexes[i],sep = ""))]
    S_p0 <- parameters$S[,startsWith(colnames(parameters$S),paste('S[',player1_indexes[i],sep = ""))]
    S1 <- S_p1 %*% X_subject[i,]
    S0 <- S_p0 %*% X_subject[i,]
  }else{
    S0<-0
    S1<-0
  }

  lambda1 <-parameters$lambda[,player1_indexes[i]] + parameters$U1_std*U11 + parameters$U2_std*U12 + parameters$U3_std*U13 +S1
  lambda0 <- parameters$lambda[,player0_indexes[i]] + parameters$U1_std*U01 + parameters$U2_std*U02 + parameters$U3_std*U03 +S0


  geom_term <- standata$use_Davidson*exp(parameters$nu+0.5*(parameters$lambda[,player1_indexes[i]]+parameters$lambda[,player0_indexes[i]]))
  p1 <- exp(lambda1)
  p0 <- exp(lambda0)

  p1_win <-  p1/(p0+p1+geom_term)
  p_tie <- geom_term/(p0+p1+geom_term)

  out <- list(
    p1_win=p1_win,
    p_tie=p_tie)

  return(out)
}

#' Bernoulli random number distribution
#' @param p probability
#' @param n the size to return
#' @return a random number 1 or 0
#' @importFrom stats rbinom
bernoulli_rng <- function(n,p){
  return(rbinom(n,1,p))
}

