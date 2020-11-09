// Davidson model generalized
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
  int <lower=1> K;//Number of predictors. We have fixed values for the predictors for both player0 and player1
  matrix [N_players, K] X;//Matrix of predictors
  real<lower=0> prior_lambda_std;
  real prior_lambda_mu;
  real prior_nu_mu;
  real<lower=0> prior_nu_std;
}

parameters {
  vector[K] B; // variable for all the predictors and players
  real  nu; // the tie parameter.
}

model {
  //variable definitions

  //priors
  B ~ normal(prior_lambda_mu, prior_lambda_std);
  nu ~ normal(prior_nu_mu,prior_nu_std);

  //model
  for (i in 1:N_total)
  {
    //local variables
    real lambda0;
    real lambda1;
    vector[K] X0;
    vector[K] X1;
    real p1_win;
    real p1;
    real p0;
    real geom_term;
    real p_draw;
    real p_1_win_not_draw;


    X0 = to_vector(X[player0_indexes[i],]);
    X1 = to_vector(X[player1_indexes[i],]);
    lambda0 = dot_product(X0,B);
    lambda1 = dot_product(X1,B);

    p0 = exp(lambda0);
    p1 = exp(lambda1);
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
  vector[N_players] lambda;
  for(i in 1:N_total){
    //local variables
    //local variables
    real lambda0;
    real lambda1;
    vector[K] X0;
    vector[K] X1;
    real p1_win;
    real p1;
    real p0;
    real geom_term;
    real p_draw;
    real p_1_win_not_draw;


    X0 = to_vector(X[player0_indexes[i],]);
    X1 = to_vector(X[player1_indexes[i],]);
    lambda0 = dot_product(X0,B);
    lambda1 = dot_product(X1,B);

    p0 = exp(lambda0);
    p1 = exp(lambda1);
    geom_term = exp(nu+0.5*(lambda0+lambda1));

    p_draw= geom_term/(p0+p1+geom_term);
    p_1_win_not_draw = p1/(p0+p1+geom_term);
    //tie
    if(ties[i]==1)   log_lik[i] = bernoulli_lpmf(ties[i] | p_draw);
    //no tie
    if(ties[i]==0)   log_lik[i] = bernoulli_lpmf(y[i] | p_1_win_not_draw);

  }

  for(i in 1:N_players){
    lambda[i] = dot_product(B,to_vector(X[i,]));
  }
}
