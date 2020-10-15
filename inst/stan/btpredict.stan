// Bradley-Terry model Predict
// Author: David Issa Mattos
// Date: 8 Oct 2020
//
//

data {
 int <lower=1> N_newdata; // Sample size of the newdata vector
 int <lower=1> N_players; // Number of players
 int <lower=1> player0_indexes[N_newdata];//input
 int <lower=1> player1_indexes[N_newdata];//input
 }

parameters{
  real lambda[N_players]; //Latent variable that represents the strength. This should be a matrix 1 row for each posterior sample 1 column for each player
}

generated quantities{
  vector[N_newdata] y_pred;
  for(i in 1:N_newdata){
      y_pred[i] = bernoulli_logit_rng(lambda[player1_indexes[i]] - lambda[player0_indexes[i]]);
  }
}
