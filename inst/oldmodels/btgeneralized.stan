// Generalized Bradley-Terry model
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
  int <lower=1> K;//Number of predictors. We have fixed values for the predictors for both player0 and player1
  matrix [N_players, K] X;//Matrix of predictors
  //Priors definitions
  real<lower=0> prior_lambda_std;
  real prior_lambda_mu;
}

parameters {
  vector[K] B; // variable for all the predictors and players
}

model {
  // variables

  //priors
  B ~ normal(prior_lambda_mu, prior_lambda_std);

  for (i in 1:N_total)
  {
    real lambda0;
    real lambda1;
    vector[K] X0;
    vector[K] X1;
    real p1_win;
    real p1;
    real p0;
    X0 = to_vector(X[player0_indexes[i],]);
    X1 = to_vector(X[player1_indexes[i],]);
    lambda0 = dot_product(X0,B);
    lambda1 = dot_product(X1,B);


    p1 = exp(lambda1);
    p0 = exp(lambda0);
    p1_win =  p1/(p0+p1);

    y[i]~bernoulli(p1_win);

  }

}



generated quantities{
  //variable definitions
  vector[N_total] log_lik;//Log likelihood
  vector[N_players] lambda;
  for(i in 1:N_total){
    //local varaibles
    real lambda0;
    real lambda1;
    vector[K] X0;
    vector[K] X1;
    real p1_win;
    real p1;
    real p0;
    X0 = to_vector(X[player0_indexes[i],]);
    X1 = to_vector(X[player1_indexes[i],]);
    lambda0 = dot_product(X0,B);
    lambda1 = dot_product(X1,B);


    p1 = exp(lambda1);
    p0 = exp(lambda0);
    p1_win =  p1/(p0+p1);

    log_lik[i] = bernoulli_lpmf(y[i] | p1_win);
  }

  //computing the ability of each player
  for(i in 1:N_players){
    lambda[i] = dot_product(B,to_vector(X[i,]));
  }
}
