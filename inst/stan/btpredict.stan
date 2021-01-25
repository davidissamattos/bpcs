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
  int <lower=0, upper=1> use_U1;
  int <lower=0> N_U1;
  int U1_indexes[use_U1 ? N_newdata : 0];

  int <lower=0, upper=1> use_U2;
  int <lower=0> N_U2;
  int U2_indexes[use_U2 ? N_newdata : 0];

  int <lower=0, upper=1> use_U3;
  int <lower=0> N_U3;
  int U3_indexes[use_U3 ? N_newdata : 0];

   // Davidson
  int <lower=0, upper=1> use_Davidson;

  int <lower=0, upper=1> use_Generalized;
  int <lower=0> K;//Number of predictors. We have fixed values for the predictors for both player0 and player1
  matrix [use_Generalized ? N_players : 0, use_Generalized ? K :0] X;//Matrix of predictors


  //Subject-predictors
 int <lower=0, upper=1> use_SubjectPredictors;
 int <lower=0> N_SubjectPredictors;
 matrix [use_SubjectPredictors ? N_newdata : 0, use_SubjectPredictors ? N_SubjectPredictors :0] X_subject;//Matrix of subject predictors


}

parameters {
  real lambda[N_players]; //Latent variable that represents the strength
  real gm;
  real <lower=0> U1_std;
  real <lower=0> U2_std;
  real <lower=0> U3_std;
  real nu;
  real U1[N_players, use_U1 ? N_U1 : 1];//even if we dont use it we have it here for the gqs to work properly
  real U2[N_players, use_U2 ? N_U2 : 1];//even if we dont use it we have it here for the gqs to work properly
  real U3[N_players, use_U3 ? N_U3 : 1];//even if we dont use it we have it here for the gqs to work properly
  real B[use_Generalized ? K : 2];//even if we dont use it we have it here for the gqs to work properly
  //due to a bug we need at least a vector of 2
  real S[N_players, use_SubjectPredictors ? N_SubjectPredictors : 1];//even if we dont use it we have it here for the gqs to work properly
}



generated quantities{
  vector[N_newdata] y_pred;
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
    real ties_pred;
    p_win_ties = calculate_p1_win_and_ties(i,
                      player1_indexes, player0_indexes, lambda_call,
                      use_Ordereffect, z_player1, gm,
                      use_Davidson, nu,
                      use_U1, U1_indexes, U1, U1_std,
                      use_U2, U2_indexes, U2, U2_std,
                      use_U3, U3_indexes, U3, U3_std,
                      use_SubjectPredictors, S, X_subject);
    p1_win = p_win_ties[1];
    p_tie= p_win_ties[2];

    ties_pred = bernoulli_rng(p_tie);
    if(ties_pred==1){
       y_pred[i] = 2;
    }
    else{
      y_pred[i] = bernoulli_rng(p1_win);
    }
  }
}
