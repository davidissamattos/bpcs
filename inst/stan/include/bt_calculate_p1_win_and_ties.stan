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
    real geom_term_switch;
    real S0;
    real S1;


    if(use_Ordereffect){
      z = z_player1[i];
    }else{
      z = 0;
    }

    if(use_U1){
      U01 = U1[player1_indexes[i], U1_indexes[i]];
      U11 = U1[player0_indexes[i], U1_indexes[i]];
    }else{
      U01 = 0;
      U11 = 0;
    }

    if(use_U2){
      U02 = U2[player1_indexes[i], U2_indexes[i]];
      U12 = U2[player0_indexes[i], U2_indexes[i]];
    }else{
      U02 = 0;
      U12 = 0;
    }

     if(use_U3){
      U03 = U3[player1_indexes[i], U3_indexes[i]];
      U13 = U3[player0_indexes[i], U3_indexes[i]];
    }else{
      U03 = 0;
      U13 = 0;
    }

    if(use_Davidson){
      geom_term_switch = 1;
    }else{
      geom_term_switch = 0;
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

    geom_term = geom_term_switch*exp(nu+0.5*(lambda[player1_indexes[i]]+lambda[player0_indexes[i]]));
    p1 = exp(lambda1);
    p0 = exp(lambda0);

    p1_win =  p1/(p0+p1+geom_term);
    p_tie = geom_term/(p0+p1+geom_term);

    return_value[1] = p1_win;
    return_value[2]= p_tie;

    return return_value;
}
