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
 real<lower=0> prior_lambda_mu;
 real<lower=0> prior_nu;
}

parameters {
  real <lower=0> lambda[N_players]; //Latent variable that represents the strength
  real <lower=0> nu; // the tie parameter. Minimum is zero so the prior will be half-normal
}

model {
  real p_draw[N_total];
  real p_not_draw[N_total];
  real nu_prod[N_total];
  real denom[N_total];
  lambda ~ normal(prior_lambda_std,prior_lambda_mu);
  nu ~ normal(0,prior_nu);//half-normal prior

  for (i in 1:N_total)
  {

     nu_prod[i] = nu*sqrt(lambda[player1_indexes[i]]*lambda[player0_indexes[i]]);
     denom[i] = nu_prod[i] + lambda[player1_indexes[i]] + lambda[player0_indexes[i]];
     p_draw[i] = nu_prod[i]/denom[i];
     p_not_draw[i] = lambda[player1_indexes[i]]/ denom[i];

   //tie
    if(ties[i]==1) target += bernoulli_lpmf(ties[i] | p_draw[i]);
    //no tie
    if(ties[i]==0) target += bernoulli_lpmf(y[i] | p_not_draw[i]);
  }
}
