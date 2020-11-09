// Bradley-Terry model with random effects Predict
// Author: David Issa Mattos
// Date: 27 Oct 2020
//
//

data {
  int <lower=1> N_newdata; // Sample size of the newdata vector
  int <lower=1> N_players; // Number of players
  int <lower=1> player0_indexes[N_newdata];//input
  int <lower=1> player1_indexes[N_newdata];//input
  int <lower=1> N_U;
  int U_indexes[N_newdata];
}

parameters{
  real  lambda[N_players]; //Latent variable that represents the strength
  real  U_std;//std for the random effects
  matrix[N_players, N_U] U; //parameters of the random effects for cluster one random effect for each algorithm in each cluster

}

generated quantities{
  vector[N_newdata] y_pred;
  for(i in 1:N_newdata){
    real p1_win;
    real p1;
    real p0;
    real lambda1;
    real lambda0;
    lambda1 = lambda[player1_indexes[i]] + U_std*U[player1_indexes[i], U_indexes[i]];
    lambda0 = lambda[player0_indexes[i]] + U_std*U[player0_indexes[i], U_indexes[i]];
    p1 = exp(lambda1);
    p0 = exp(lambda0);
    p1_win =  p1/(p0+p1);
    y_pred[i] = bernoulli_rng(p1_win);
  }
}
