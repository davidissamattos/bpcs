// Davidson model Predict with order effect
// Author: David Issa Mattos
// Date: 23 Oct 2020
//
//

data {
 int <lower=1> N_newdata; // Sample size of the newdata vector
 int <lower=1> N_players; // Number of players
 int <lower=1> player0_indexes[N_newdata];//input
 int <lower=1> player1_indexes[N_newdata];//input
 real z[N_newdata];//1 home advantage for player 1. 0 no home advantage. -1 home advantage for player 0

 }

parameters{
  real lambda[N_players]; //Latent variable that represents the strength
  real  nu; // the tie parameter.
  real  gm;//Represents the order effect gamma
}

generated quantities{
  vector[N_newdata] y_pred;
  vector[N_newdata] ties_pred;
  for(i in 1:N_newdata){
    real p0;
    real p1;
    real geom_term;
    real p_draw;
    real p_1_win_not_draw;

    p0 = exp(lambda[player0_indexes[i]]+gm*z[i]);
    p1 = exp(lambda[player1_indexes[i]]);
    geom_term = exp(nu+0.5*(gm*z[i]+lambda[player0_indexes[i]]+lambda[player1_indexes[i]]));

    p_draw= geom_term/(p0+p1+geom_term);
    p_1_win_not_draw = p1/(p0+p1+geom_term);
   //tie
    ties_pred[i] = bernoulli_rng(p_draw);
   //no tie
    y_pred[i] = bernoulli_rng(p_1_win_not_draw);
  }
}