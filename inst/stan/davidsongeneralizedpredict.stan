// Davidson model Predict
// Author: David Issa Mattos
// Date: 23 Oct 2020
//
//

data {
  int <lower=1> N_newdata; // Sample size of the newdata vector
  int <lower=1> N_players; // Number of players
  int <lower=1> player0_indexes[N_newdata];//input
  int <lower=1> player1_indexes[N_newdata];//input
  int <lower=1> K;//Number of predictors. We have fixed values for the predictors for both player0 and player1
  matrix [N_players, K] X;//Matrix of predictors
}

parameters{
  vector[K] B; // variable for all the predictors and players
  real  nu; // the tie parameter.
}

generated quantities{
  vector[N_newdata] y_pred;
  vector[N_newdata] ties_pred;
  for(i in 1:N_newdata){
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
    ties_pred[i] = bernoulli_rng(p_draw);
    //no tie
    y_pred[i] = bernoulli_rng(p_1_win_not_draw);
  }
}
