// Davidson model with random effects Predict
// Author: David Issa Mattos
// Date: 28 Oct 2020
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
  real nu; // the tie parameter.
  real  U_std;//std for the random effects
  matrix[N_players, N_U] U; //parameters of the random effects for cluster one random effect for each algorithm in each cluster

}

generated quantities{
  vector[N_newdata] y_pred;
  vector[N_newdata] ties_pred;
  for(i in 1:N_newdata){
    real p1;
    real p0;
    real geom_term;
    real p_draw;
    real p_1_win_not_draw;
    real lambda1;
    real lambda0;

    lambda1 = lambda[player1_indexes[i]] + U_std*U[player1_indexes[i], U_indexes[i]];
    lambda0 = lambda[player0_indexes[i]] + U_std*U[player0_indexes[i], U_indexes[i]];
    p1 = exp(lambda1);
    p0 = exp(lambda0);

    geom_term = exp(nu+0.5*(lambda0+lambda1));

    p_draw= geom_term/(p0+p1+geom_term);
    p_1_win_not_draw = p1/(p0+p1+geom_term);
   //tie
    ties_pred[i] = bernoulli_rng(p_draw);
   //no tie
    y_pred[i] = bernoulli_rng(p_1_win_not_draw);
  }
}
