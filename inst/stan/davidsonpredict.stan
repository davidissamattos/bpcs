// Davidson model Predict
// Author: David Issa Mattos
// Date: 23 Oct 2020
//
//

data {
 int <lower=1> N_newdata; // Sample size of the newdata vector
 int <lower=1> N_players; // Number of players
 int <lower=1> player0_indexes[N_newdata];//input
 int <lower=1> player1_indexes[N_newdata];//input
 }

parameters{
  real lambda[N_players]; //Latent variable that represents the strength.
  real <lower=0> nu; //tie parameter
}

generated quantities{
  vector[N_newdata] y_pred;
  vector[N_newdata] ties_pred;
  for(i in 1:N_newdata){
   //tie
    ties_pred[i] = bernoulli_rng(nu*sqrt(lambda[player1_indexes[i]]*lambda[player0_indexes[i]])/(nu*sqrt(lambda[player1_indexes[i]]*lambda[player0_indexes[i]])+ lambda[player1_indexes[i]] + lambda[player0_indexes[i]]));
   //no tie
    y_pred[i] = bernoulli_rng(lambda[player1_indexes[i]]/(nu*sqrt(lambda[player1_indexes[i]]*lambda[player0_indexes[i]])+ lambda[player1_indexes[i]] + lambda[player0_indexes[i]]));
  }
}
