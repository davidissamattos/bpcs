// Bradley-Terry model
// Author: David Issa Mattos

functions{
#include /include/bt_calculate_p1_win_and_ties.stan
}

data {
  int <lower=1> N_total; // Sample size
  int <lower=0, upper=2> y[N_total]; //variable that indicates which one wins player0 or player1
  int <lower=0, upper=1> ties[N_total];
  int <lower=1> N_players; // Number of players
  int <lower=1> player0_indexes[N_total];
  int <lower=1> player1_indexes[N_total];

  // ORDER EFFECT
  int <lower=0, upper=1> use_Ordereffect;
  real z_player1[use_Ordereffect ? N_total : 0]; //1 home advantage for player 1. 0 no home advantage.

  // U for random effects
  int <lower=0, upper=1> use_U;
  int <lower=0> N_U;
  int U_indexes[use_U ? N_total : 0];

  // Davidson
  int <lower=0, upper=1> use_Davidson;

  // Generalized
  int <lower=0, upper=1> use_Generalized;
  int <lower=0> K;//Number of predictors. We have fixed values for the predictors for both player0 and player1
  matrix [use_Generalized ? N_players : 0, use_Generalized ? K :0] X;//Matrix of predictors


  //Priors
  //lambda
  real<lower=0> prior_lambda_std;
  real prior_lambda_mu;
  //gm ordereffect
  real<lower=0> prior_gm_std;
  real prior_gm_mu;
  // random effects
  real<lower=0> prior_U_std;
  // davidson draw parameter
  real prior_nu_mu;
  real<lower=0> prior_nu_std;
}

parameters {
  real lambda_param[N_players]; //Latent variable that represents the strength

  // Order effect
  real gm_param[use_Ordereffect ? 1: 0];//Represents the order effect gamma

  // U
  real <lower=0> U_std_param[use_U ? 1: 0];//std for the random effects
  // Matrix N_players x N_U if use_U is 1 else 0x0
  real U_param[use_U ? N_players : 0, use_U ? N_U : 0]; //parameters of the random effects for cluster one random effect for each algorithm in each cluster

  //Davidson
  real  nu_param[use_Davidson ? 1 : 0]; // the tie parameter.

  //Generalized
  real B_param[use_Generalized ? K :0]; // variable for all the predictors and players
}

transformed parameters{

  real lambda[N_players];
  real gm;
  real <lower=0> U_std;
  real nu;
  real B[use_Generalized ? K : 2]; //due to a bug we need at least a vector of 2
  real U[N_players, use_U ? N_U : 1];//even if we dont use it we have it here for the gqs to work properly

  // order effect
  if(use_Ordereffect){
    gm = gm_param[1];
  }else{
    gm = 0;
  }

  // U
  if(use_U){
    U_std = U_std_param[1];
    U = U_param;
  }else{
    U_std = 0;
    for (i in 1:N_players)
    {
        U[i, 1]= 0;
    }
  }

  // Davidson
  if(use_Davidson){
    nu = nu_param[1];
  }else{
    nu = 0;
  }

  //Generalized
  if(use_Generalized){
    B = B_param;
    for(i in 1:N_players){
      lambda[i] = dot_product(to_vector(B_param),to_vector(X[i,]));
    }
  } else{
    B[1] = 0;
    B[2] = 0;
    lambda = lambda_param;
  }

}

model {
  //priors
  lambda_param ~ normal(prior_lambda_mu,prior_lambda_std);

  if(use_Ordereffect){
    gm_param ~ normal(prior_gm_mu,prior_gm_std);
  }
  if(use_U){
    U_std_param ~ normal(0,prior_U_std);//Halfnormal
    for (i in 1:N_players)
    {
      for(j in 1:N_U){
        U_param[i, j] ~ normal(0, 1);//we dont add U_std here for numerical reasons
      }
    }
  }
  if(use_Davidson){
     nu_param ~ normal(prior_nu_mu,prior_nu_std);
  }
  if(use_Generalized){
     B_param ~ normal(prior_lambda_mu, prior_lambda_std);
  }

  //model
  for (i in 1:N_total)
  {
    real p1_win;
    real p_tie;
    real p_win_ties[2];
    p_win_ties = calculate_p1_win_and_ties(i,
                       use_Ordereffect,  use_U, use_Davidson,//data switches
                       player1_indexes,  player0_indexes, //data vectors
                       z_player1,  U_indexes,
                       U, lambda,  U_std,  gm, nu);//parameters
    p1_win = p_win_ties[1];
    p_tie= p_win_ties[2];

    //tie
    if(ties[i]==1) target += bernoulli_lpmf(ties[i] | p_tie);
    //no tie
    if(ties[i]==0) target += bernoulli_lpmf(y[i] | p1_win);
  }
}



generated quantities{
  //variable definitions
  vector[N_total] log_lik;//Log likelihood

   for (i in 1:N_total)
  {
    real p1_win;
    real p_tie;
    real p_win_ties[2];
    p_win_ties = calculate_p1_win_and_ties(i,
                       use_Ordereffect,  use_U, use_Davidson,//data switches
                       player1_indexes,  player0_indexes, //data vectors
                       z_player1,  U_indexes,
                       U, lambda,  U_std,  gm, nu);//parameters
    p1_win = p_win_ties[1];
    p_tie= p_win_ties[2];

  //parameters
    if(ties[i]==1)   log_lik[i] = bernoulli_lpmf(ties[i] | p_tie);
    //no tie
    if(ties[i]==0)   log_lik[i] = bernoulli_lpmf(y[i] | p1_win);
  }
}
