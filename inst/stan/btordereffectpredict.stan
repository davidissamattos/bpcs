// Bradley-Terry model with order effect Predict
// Author: David Issa Mattos
// Date: 27 Oct 2020


data {
 int <lower=1> N_newdata; // Sample size of the newdata vector
 int <lower=1> N_players; // Number of players
 int <lower=1> player0_indexes[N_newdata];//input
 int <lower=1> player1_indexes[N_newdata];//input
 int  z_player1[N_newdata];//input
 }

parameters{
  real  lambda[N_players]; //Latent variable that represents the strength. This should be a matrix 1 row for each posterior sample 1 column for each player
  real  gm;//Represents the order effect gamma
}

generated quantities{
  vector[N_newdata] y_pred;
  for(i in 1:N_newdata){
    real p1_win;
    real p1;
    real p0;
    p1 = exp(lambda[player1_indexes[i]]);
    p0 = exp(lambda[player0_indexes[i]]+gm*z_player1[i]);
    p1_win =  p1/(p0+p1);
    y_pred[i] = bernoulli_rng(p1_win);
  }
}
