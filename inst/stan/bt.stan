// Bradley-Terry model
// Author: David Issa Mattos
// Date: 8 Oct 2020
//
//

data {
  int <lower=1> N_total; // Sample size
  int <lower=0, upper=1> y[N_total]; //variable that indicates which one wins player0 or player1
  int <lower=1> N_players; // Number of players
  int <lower=1> player0_indexes[N_total];
  int <lower=1> player1_indexes[N_total];
  real<lower=0> prior_lambda_std;
  real prior_lambda_mu;
}

parameters {
  real lambda[N_players]; //Latent variable that represents the strength
}

model {
  //variable definitions
  //priors
  lambda ~ normal(prior_lambda_mu,prior_lambda_std);

  //model
  for (i in 1:N_total)
  {
    real p1_win;
    real p1;
    real p0;
    p1 = exp(lambda[player1_indexes[i]]);
    p0 = exp(lambda[player0_indexes[i]]);
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
    p1 = exp(lambda[player1_indexes[i]]);
    p0 = exp(lambda[player0_indexes[i]]);
    p1_win =  p1/(p0+p1);
    log_lik[i] = bernoulli_lpmf(y[i]| p1_win);
  }
}
