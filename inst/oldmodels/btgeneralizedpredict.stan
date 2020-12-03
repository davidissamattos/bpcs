// Generalized Bradley-Terry model to predict
// Author: David Issa Mattos
// Date: 27 Oct 2020
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


parameters {
  vector[K] B; // variable for all the predictors and players
}


generated quantities{
  //variables
  vector[N_players] y_pred;
  for(i in 1:N_newdata){
    //local variables
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

    //posterior predictive
    y_pred[i] = bernoulli_rng(p1_win);
  }
}
