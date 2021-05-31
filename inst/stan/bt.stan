// Bradley-Terry and Davidson model
// Author: David Issa Mattos
// This model is part of the bpcs package
// Feel free to use it and adapt it but include the citation:
//
// Mattos, D. I., & Ramos, É. M. S. (2021). Bayesian Paired-Comparison with the bpcs Package. arXiv preprint arXiv:2101.11227
//

functions{
real[] calculate_p1_win_and_ties(int i,
                      int[] player1_indexes, int[] player0_indexes, real[] lambda,
                      int use_Ordereffect, real[] z_player1, real gm,
                      int use_Davidson, real nu,
                      int use_U1, int[] U1_indexes, real[,] U1, real U1_std,
                      int use_U2, int[] U2_indexes, real[,] U2, real U2_std,
                      int use_U3, int[] U3_indexes, real[,] U3, real U3_std,
                      int use_SubjectPredictors, real[,] S ,matrix X_subject)
{

    //Probabilities
    real p1_win;
    real p_tie;
    real p1;
    real p0;
    real lambda1;
    real lambda0;
    real return_value[2];

    //Transformed varaibles for the conditional uses
    real z;
    real U01;//cluster1
    real U11;//cluster1
    real U02;//cluster2
    real U12;//cluster2
    real U03;//cluster3
    real U13;//cluster3
    real tie;
    real geom_term;
    real S0;
    real S1;

    if(use_Ordereffect){
      z = z_player1[i];
    }else{
      z = 0;
    }

    if(use_U1){
      U01 = U1[player0_indexes[i], U1_indexes[i]];
      U11 = U1[player1_indexes[i], U1_indexes[i]];
    }else{
      U01 = 0;
      U11 = 0;
    }

    if(use_U2){
      U02 = U2[player0_indexes[i], U2_indexes[i]];
      U12 = U2[player1_indexes[i], U2_indexes[i]];
    }else{
      U02 = 0;
      U12 = 0;
    }

     if(use_U3){
      U03 = U3[player0_indexes[i], U3_indexes[i]];
      U13 = U3[player1_indexes[i], U3_indexes[i]];
    }else{
      U03 = 0;
      U13 = 0;
    }


    if(use_SubjectPredictors){
      S1 =  dot_product(to_vector(S[player1_indexes[i],]),to_vector(X_subject[i,]));
      S0 =  dot_product(to_vector(S[player0_indexes[i],]),to_vector(X_subject[i,]));
    }else{
      S0 = 0;
      S1 = 0;
    }

    lambda1 = lambda[player1_indexes[i]] + U1_std*U11 + U2_std*U12 + U3_std*U13 + S1;
    lambda0 = lambda[player0_indexes[i]] + U1_std*U01 + U2_std*U02 + U3_std*U03 + gm*z + S0;



    geom_term = use_Davidson*exp(nu+0.5*(lambda[player1_indexes[i]]+lambda[player0_indexes[i]]));
    p1 = exp(lambda1);
    p0 = exp(lambda0);

    p1_win =  p1/(p0+p1+geom_term);
    p_tie = geom_term/(p0+p1+geom_term);

    return_value[1] = p1_win;
    return_value[2]= p_tie;

    return return_value;
}


}

data {
  int <lower=1> N_total; // Sample size
  int <lower=0, upper=2> y[N_total]; //variable that indicates which one wins player0 or player1
  int <lower=1> N_players; // Number of players
  int <lower=1> player0_indexes[N_total];
  int <lower=1> player1_indexes[N_total];

  // ORDER EFFECT
  int <lower=0, upper=1> use_Ordereffect;
  real z_player1[use_Ordereffect ? N_total : 0]; //1 home advantage for player 1. 0 no home advantage.

  // U for random effects
  int <lower=0, upper=1> use_U1;
  int <lower=0> N_U1;
  int U1_indexes[use_U1 ? N_total : 0];

  int <lower=0, upper=1> use_U2;
  int <lower=0> N_U2;
  int U2_indexes[use_U2 ? N_total : 0];

  int <lower=0, upper=1> use_U3;
  int <lower=0> N_U3;
  int U3_indexes[use_U3 ? N_total : 0];

 //Subject-predictors
 int <lower=0, upper=1> use_SubjectPredictors;
 int <lower=0> N_SubjectPredictors;
 matrix [use_SubjectPredictors ? N_total : 0, use_SubjectPredictors ? N_SubjectPredictors :0] X_subject;//Matrix of subject predictors


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
  real<lower=0> prior_U1_std;
  real<lower=0> prior_U2_std;
  real<lower=0> prior_U3_std;
  // davidson draw parameter
  real prior_nu_mu;
  real<lower=0> prior_nu_std;
  //subject predictors
  real<lower=0> prior_S_std;

  int <lower=0, upper=1> calc_log_lik;
}

parameters {
  real lambda_param [N_players]; //Latent variable that represents the strength

  // Order effect
  real gm_param[use_Ordereffect ? 1: 0];//Represents the order effect gamma
    //Davidson
  real nu_param[use_Davidson ? 1 : 0]; // the tie parameter.
  // U
  real <lower=0> U1_std_param[use_U1 ? 1: 0];//std for the random effects
  // Matrix N_players x N_U if use_U is 1 else 0x0
  real U1_param[use_U1 ? N_players : 0, use_U1 ? N_U1 : 0]; //parameters of the random effects for cluster one random effect for each algorithm in each cluster
  real <lower=0> U2_std_param[use_U2 ? 1: 0];//std for the random effects
  // Matrix N_players x N_U if use_U is 1 else 0x0
  real U2_param[use_U2 ? N_players : 0, use_U2 ? N_U2 : 0]; //parameters of the random effects for cluster one random effect for each algorithm in each cluster
  real <lower=0> U3_std_param[use_U3 ? 1: 0];//std for the random effects
  // Matrix N_players x N_U if use_U is 1 else 0x0
  real U3_param[use_U3 ? N_players : 0, use_U3 ? N_U3 : 0]; //parameters of the random effects for cluster one random effect for each algorithm in each cluster

  //Subject predictors
  //We have vector of suuject predictors for every player
  real S_param[use_SubjectPredictors ? N_players :0, use_SubjectPredictors ? N_SubjectPredictors :0];

  //Generalized
  real B_param[use_Generalized ? K :0]; // variable for all the predictors and players
}

transformed parameters{

  real lambda[N_players];
  real gm;
  real nu;


  real <lower=0> U1_std;
  real U1[N_players, use_U1 ? N_U1 : 1];//even if we dont use it we have it here for the gqs to work properly

  real <lower=0> U2_std;
  real U2[N_players, use_U2 ? N_U2 : 1];//even if we dont use it we have it here for the gqs to work properly

  real <lower=0> U3_std;
  real U3[N_players, use_U3 ? N_U3 : 1];//even if we dont use it we have it here for the gqs to work properly

  real S[N_players, use_SubjectPredictors ? N_SubjectPredictors : 1];
  real B[use_Generalized ? K : 1]; //due to a bug we need at least a vector of 2

      // Davidson
  if(use_Davidson){
    nu = nu_param[1];
  }else{
    nu = 0;
  }

  // order effect
  if(use_Ordereffect){
    gm = gm_param[1];
  }else{
    gm = 0;
  }

  // U
  if(use_U1){
    U1_std = U1_std_param[1];
    U1 = U1_param;
  } else{
    U1_std = 0;
    for (i in 1:N_players)
    {
        U1[i, 1]= 0;
    }
  }

  // U
  if(use_U2){
    U2_std = U2_std_param[1];
    U2 = U2_param;
  }else{
    U2_std = 0;
    for (i in 1:N_players)
    {
        U2[i, 1]= 0;
    }
  }

  if(use_U3){
    U3_std = U3_std_param[1];
    U3 = U3_param;
  }else{
    U3_std = 0;
    for (i in 1:N_players)
    {
      U3[i, 1]= 0;
    }
  }

  //Subject Predictors
  if(use_SubjectPredictors){
    S = S_param;
  } else{
    for (i in 1:N_players)
    {
      S[i, 1]= 0;
    }
  }

  //Generalized
  if(use_Generalized){
    B = B_param;
    for(i in 1:N_players){
      lambda[i] = dot_product(to_vector(B_param),to_vector(X[i,]));
    }
  } else{
    B[1] = 0;
    lambda = lambda_param;
  }


}

model {
    lambda_param ~ normal(prior_lambda_mu,prior_lambda_std);

    if(use_Ordereffect){
      gm_param ~ normal(prior_gm_mu,prior_gm_std);
    }


    if(use_U1){
    U1_std_param ~ normal(0,prior_U1_std);//Halfnormal
    // U1_std_param ~ exponential(1);
    for (i in 1:N_players)
    {
      for(j in 1:N_U1){
        U1_param[i, j] ~ normal(0, 1);//we dont add U_std here for numerical reasons
      }
    }
  }

    if(use_U2){
    U2_std_param ~ normal(0,prior_U2_std);//Halfnormal
    // U2_std_param ~ exponential(1);
    for (i in 1:N_players)
    {
      for(j in 1:N_U2){
        U2_param[i, j] ~ normal(0, 1);//we dont add U_std here for numerical reasons
      }
    }
  }

    if(use_U3){
    U3_std_param ~ normal(0,prior_U3_std);//Halfnormal
    // U3_std_param ~ exponential(1);
    for (i in 1:N_players)
    {
      for(j in 1:N_U3){
        U3_param[i, j] ~ normal(0, 1);//we dont add U_std here for numerical reasons
      }
    }
  }

  if(use_Davidson){
     nu_param ~ normal(prior_nu_mu,prior_nu_std);
  }

  if(use_Generalized){
     B_param ~ normal(prior_lambda_mu, prior_lambda_std);
  }

  if(use_SubjectPredictors){
    for (i in 1:N_players)
    {
      for(j in 1:N_SubjectPredictors){
        S_param[i, j] ~ normal(0, prior_S_std);
      }
    }
  }


  //model
  for (i in 1:N_total)
  {
    real p1_win;
    real p_tie;
    real p_win_ties[2];


    p_win_ties = calculate_p1_win_and_ties(i,
                      player1_indexes, player0_indexes, lambda,
                      use_Ordereffect, z_player1, gm,
                      use_Davidson, nu,
                      use_U1, U1_indexes, U1, U1_std,
                      use_U2, U2_indexes,U2, U2_std,
                      use_U3, U2_indexes,U3, U3_std,
                      use_SubjectPredictors, S, X_subject);
    p1_win = p_win_ties[1];
    p_tie= p_win_ties[2];

    //tie
    if(y[i]==2){
       target += bernoulli_lpmf(1 | p_tie);
    }
    else{
      target += bernoulli_lpmf(y[i] | p1_win);
    }

  }
}



generated quantities{
vector[calc_log_lik ? N_total: 0] log_lik;//Log likelihood

  if(calc_log_lik){
    for (i in 1:N_total)
    {
    real p1_win;
    real p_tie;
    real p_win_ties[2];

    p_win_ties = calculate_p1_win_and_ties(i,
                      player1_indexes, player0_indexes, lambda,
                      use_Ordereffect, z_player1, gm,
                      use_Davidson, nu,
                      use_U1, U1_indexes, U1, U1_std,
                      use_U2, U2_indexes,U2, U2_std,
                      use_U3, U2_indexes,U3, U3_std,
                      use_SubjectPredictors, S, X_subject);
    p1_win = p_win_ties[1];
    p_tie= p_win_ties[2];

  //parameters
  //Probability of being a tie
    if(y[i]==2){
      log_lik[i] = bernoulli_lpmf(1 | p_tie);
    }
    else{
      log_lik[i] = bernoulli_lpmf(y[i] | p1_win);
    }
  }
}



}
