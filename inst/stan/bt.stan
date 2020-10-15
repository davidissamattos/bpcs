// Bradley-Terry model
// Author: David Issa Mattos
// Date: 8 Oct 2020
//
//

data {
 int <lower=1> N_total; // Sample size
 int y[N_total]; //variable that indicates which one wins player0 or player1
 int <lower=1> N_players; // Number of players
 int <lower=1> player0_indexes[N_total];
 int <lower=1> player1_indexes[N_total];
 real<lower=0> prior_lambda_std;
}

parameters {
  real lambda[N_players]; //Latent variable that represents the strength
}

model {
  real p[N_total];
  lambda ~ normal(0,prior_lambda_std);


  for (i in 1:N_total)
  {
     p[i] = lambda[player1_indexes[i]] - lambda[player0_indexes[i]];
  }

  y ~ bernoulli_logit(p);
}



generated quantities{
  vector[N_total] log_lik;
  for(i in 1:N_total){
    real p;
    p = lambda[player1_indexes[i]] - lambda[player0_indexes[i]];
    //Log likelihood
     log_lik[i] = bernoulli_logit_lpmf(y[i] | p);
  }
}
