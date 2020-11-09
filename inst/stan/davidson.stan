// Davidson model
// Author: David Issa Mattos
// Date: 8 Oct 2020
//

data {
  int <lower=1> N_total; // Sample size
  int <lower=0, upper=2> y[N_total]; //variable that indicates which one wins player0 or player1
  int <lower=1> N_players; // Number of players
  int <lower=1> player0_indexes[N_total];
  int <lower=1> player1_indexes[N_total];
  int <lower=0, upper=1> ties[N_total];
  real<lower=0> prior_lambda_std;
  real prior_lambda_mu;
  real prior_nu_mu;
  real<lower=0> prior_nu_std;
}

parameters {
  real  lambda[N_players]; //Latent variable that represents the strength
  real  nu; // the tie parameter.
}

model {
  //variable definitions

  //priors
  lambda ~ normal(prior_lambda_mu,prior_lambda_std);
  nu ~ normal(prior_nu_mu,prior_nu_std);

  //model
  for (i in 1:N_total)
  {
    //local variables
    real p0;
    real p1;
    real geom_term;
    real p_draw;
    real p_1_win_not_draw;

    p0 = exp(lambda[player0_indexes[i]]);
    p1 = exp(lambda[player1_indexes[i]]);
    geom_term = exp(nu+0.5*(lambda[player0_indexes[i]]+lambda[player1_indexes[i]]));

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

    p0 = exp(lambda[player0_indexes[i]]);
    p1 = exp(lambda[player1_indexes[i]]);
    geom_term = exp(nu+0.5*(lambda[player0_indexes[i]]+lambda[player1_indexes[i]]));

    p_draw= geom_term/(p0+p1+geom_term);
    p_1_win_not_draw = p1/(p0+p1+geom_term);
    //tie
    if(ties[i]==1)   log_lik[i] = bernoulli_lpmf(ties[i] | p_draw);
    //no tie
    if(ties[i]==0)   log_lik[i] = bernoulli_lpmf(y[i] | p_1_win_not_draw);

  }
}
