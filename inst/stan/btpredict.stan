// Bradley-Terry model Predict
// Author: David Issa Mattos
// Date: 8 Oct 2020
//
//
functions{
#include /include/bt_calculate_p1_win_and_ties.stan
}

data {
  int <lower=1> N_newdata; // Sample size of the newdata vector
  int <lower=1> N_players; // Number of players
  int <lower=1> player0_indexes[N_newdata];//input
  int <lower=1> player1_indexes[N_newdata];//input

// ORDER EFFECT
  int <lower=0, upper=1> use_Ordereffect;
  real z_player1[use_Ordereffect ? N_newdata : 0]; //1 home advantage for player 1. 0 no home advantage.

  // U for random effects
  int <lower=0, upper=1> use_U;
  int <lower=0> N_U;
  int U_indexes[use_U ? N_newdata : 0];

   // Davidson
  int <lower=0, upper=1> use_Davidson;

  int <lower=0, upper=1> use_Generalized;
  int <lower=0> K;//Number of predictors. We have fixed values for the predictors for both player0 and player1
  matrix [use_Generalized ? N_players : 0, use_Generalized ? K :0] X;//Matrix of predictors

}

parameters {
  real lambda[N_players]; //Latent variable that represents the strength
  real gm;
  real <lower=0> U_std;
  real nu;
  real U[N_players, use_U ? N_U : 1];//even if we dont use it we have it here for the gqs to work properly
  real B[use_Generalized ? K : 2];//even if we dont use it we have it here for the gqs to work properly
  //due to a bug we need at least a vector of 2
}



generated quantities{
  vector[N_newdata] y_pred;
  vector[N_newdata] ties_pred;

  real lambda_call[N_players];

  //If we are doing a Generalized model we first need to convert the BX to lambda in case we have new predictors matrix
  if(use_Generalized){
    for(i in 1:N_players){
      lambda_call[i] = dot_product(to_vector(B),to_vector(X[i,]));
    }
  }else{
    lambda_call=lambda;
  }

  for (i in 1:N_newdata)
  {
    real p1_win;
    real p_tie;
    real p_win_ties[2];
    p_win_ties = calculate_p1_win_and_ties(i,
                       use_Ordereffect,  use_U, use_Davidson,//data switches
                       player1_indexes,  player0_indexes, //data vectors
                       z_player1,  U_indexes,
                       U, lambda_call,  U_std,  gm, nu);//parameters
    p1_win = p_win_ties[1];
    p_tie= p_win_ties[2];

   //tie
    ties_pred[i] = bernoulli_rng(p_tie);
   //no tie
    y_pred[i] = bernoulli_rng(p1_win);
  }
}
