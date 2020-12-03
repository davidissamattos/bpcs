real[] calculate_p1_win_and_ties(int i,
                      int use_Ordereffect, int use_U, int use_Davidson, //data switches
                      int[] player1_indexes, int[] player0_indexes, //data vectors
                      real[] z_player1, int[] U_indexes,
                      real[,] U, real[] lambda, real U_std, real gm, real nu) //parameters
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
    real U0;
    real U1;
    real tie;
    real geom_term;
    real geom_term_switch;


    if(use_Ordereffect){
      z = z_player1[i];
    }else{
      z = 0;
    }
    if(use_U){
      U0 = U[player1_indexes[i], U_indexes[i]];
      U1 = U[player0_indexes[i], U_indexes[i]];
    }else{
      U0 = 0;
      U1 = 0;
    }
    if(use_Davidson){
      geom_term_switch = 1;
    }else{
      geom_term_switch = 0;
    }

    lambda1 = lambda[player1_indexes[i]] + U_std*U1;
    lambda0 = lambda[player0_indexes[i]] + U_std*U0 + gm*z;

    geom_term = geom_term_switch*exp(nu+0.5*(lambda[player1_indexes[i]]+lambda[player0_indexes[i]]));
    p1 = exp(lambda1);
    p0 = exp(lambda0);

    p1_win =  p1/(p0+p1+geom_term);
    p_tie = geom_term/(p0+p1+geom_term);

    return_value[1] = p1_win;
    return_value[2]= p_tie;

    return return_value;
}
