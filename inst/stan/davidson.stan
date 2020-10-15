// // Davidson model
// // Author: David Issa Mattos
// // NOT WORKING YET
// //
// //
//
// data {
//  int <lower=1> N_total; // Sample size
//  int winner[N_total]; //variable that indicates which one wins player0 or player1
//  int <lower=0, upper=1>ties[N_total];//a varaible that indicates if it was a tie or not. This will superseed the above
//
//  int <lower=1> N_players; // Number of players
//
//  int <lower=1> player0_indexes[N_total];
//  int <lower=1> player1_indexes[N_total];
//
//  real<lower=0> prior_lambda_std;
// }
//
// parameters {
//   real lambda[N_players]; //Latent variable that represents the strength
//   real <lower=0> nu;
// }
//
// model {
//   real p[N_total];
//   lambda ~ normal(0,prior_lambda_std);
//   nu ~ normal(0,5);
//
//   for (i in 1:N_total)
//   {
//      p[i] = lambda[player1_indexes[i]] - lambda[player0_indexes[i]];
//   //tie
//     if(ties[i]==1) target += exponential_lpdf(y[i] | inv_logit( log(nu*sqrt(p[i])*sqrt(1-p[i]))) );
//     //no
//     if(ties[i]==0) target += exponential_lccdf(y[i] | inv_logit(p[i]) );
//   }
//
//   y ~ bernoulli_logit(p);
// }

