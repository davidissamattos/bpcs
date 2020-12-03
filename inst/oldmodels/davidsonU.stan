// Davidson model with random effects
// Author: David Issa Mattos
// Date: 28 Oct 2020
//

data {
  int <lower=1> N_total; // Sample size
  int <lower=0, upper=2> y[N_total]; //variable that indicates which one wins player0 or player1
  int <lower=1> N_players; // Number of players
  int <lower=1> player0_indexes[N_total];
  int <lower=1> player1_indexes[N_total];
  int <lower=0, upper=1> ties[N_total];

  // To model the influence of each cluster/random effect
  int <lower=1> N_U;
  int U_indexes[N_total];

  real<lower=0> prior_U_std;
  real<lower=0> prior_lambda_std;
  real prior_lambda_mu;
  real<lower=0> prior_nu_std;
  real prior_nu_mu;
}

parameters {
  real  lambda[N_players]; //Latent variable that represents the strength
  real nu; // the tie parameter.
  real  U_std;//std for the random effects
  matrix[N_players, N_U] U; //parameters of the random effects for cluster one random effect for each algorithm in each cluster
}

model {
  //variable definitions

  //priors
  nu ~ normal(prior_nu_mu,prior_nu_std);//half-normal prior
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
    //local variables
    real p0;
    real p1;
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
    if(ties[i]==1) target += bernoulli_lpmf(ties[i] | p_draw);
    //no tie
    if(ties[i]==0) target += bernoulli_lpmf(y[i] | p_1_win_not_draw);
  }
}


generated quantities{
  //variable definitions
  vector[N_total] log_lik; // log likelihood
  for(i in 1:N_total){
    //local variables
    real p0;
    real p1;
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
    if(ties[i]==1)   log_lik[i] = bernoulli_lpmf(ties[i] | p_draw);
    //no tie
    if(ties[i]==0)   log_lik[i] = bernoulli_lpmf(y[i] | p_1_win_not_draw);

  }
}
