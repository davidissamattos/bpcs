// Bradley-Terry model with random effects
// Author: David Issa Mattos
// Date: 27 Oct 2020
//
//

data {
  int <lower=1> N_total; // Sample size
  int <lower=0, upper=1> y[N_total]; //variable that indicates which one wins player0 or player1
  int <lower=1> N_players; // Number of players
  int <lower=1> player0_indexes[N_total];
  int <lower=1> player1_indexes[N_total];

  // To model the influence of each cluster/random effect
  int <lower=1> N_U;
  int U_indexes[N_total];

  real<lower=0> prior_lambda_std;
  real prior_lambda_mu;
  real<lower=0> prior_U_std;

}

parameters {
  real lambda[N_players]; //Latent variable that represents the strength
  real  U_std;//std for the random effects
  matrix[N_players, N_U] U; //parameters of the random effects for cluster one random effect for each algorithm in each cluster
}

model {
  //variable definitions
  real p[N_total];

  //priors
  U_std ~ normal(0,prior_U_std);//Halfnormal
  lambda ~ normal(prior_lambda_mu,prior_lambda_std);
  for (i in 1:N_players)
  {
    for(j in 1:N_U){
      U[i, j] ~ normal(0, 1);//we dont add U_std here for numerical reasons
    }
  }

  //model
  for (i in 1:N_total)
  {

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
    y[i] ~ bernoulli(p1_win);
  }
}



generated quantities{
  //variable definitions
  vector[N_total] log_lik;//Log likelihood
  for(i in 1:N_total){
    //local variables
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
    log_lik[i] = bernoulli_lpmf(y[i] | p1_win);
  }
}
