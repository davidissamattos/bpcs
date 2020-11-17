test_that('check_result_column works',{
  v1 <- data.frame(results=c(1,0,2,0,0,1))#true
  v2 <- data.frame(results=c(1,1.2,2,0,0,1))#false
  v3 <- data.frame(results=c(1,2,-1,0,0,1))#false
  v4 <- data.frame(results=c(1,1,2,0,0,1,'a'))#false
  expect_true(check_result_column(v1$results))
  expect_false(check_result_column(v2$results))
  expect_false(check_result_column(v3$results))
  expect_false(check_result_column(v4$results))
})

test_that('check_z_column works',{
  v1 <- data.frame(z=c(1,0,1,0,0,1))#true
  v2 <- data.frame(z=c(1,1.2,2,0,0,1))#false
  v3 <- data.frame(z=c(1,2,-1,0,0,1))#false
  v4 <- data.frame(z=c(1,1,2,0,0,1,'a'))#false
  expect_true(check_z_column(v1$z))
  expect_false(check_z_column(v2$z))
  expect_false(check_z_column(v3$z))
  expect_false(check_z_column(v4$z))
})

test_that('check_if_there_are_ties works',{
  v1 <- data.frame(results=c(1,0,2,0,0,1))#true
  v2 <- data.frame(results=c(1,1,1,0,0,1))#false
  v3 <- data.frame(results=c(1,1,0,0,1))#false
  expect_true(check_if_there_are_ties(v1$results))
  expect_false(check_if_there_are_ties(v2$results))
  expect_false(check_if_there_are_ties(v3$results))
})

test_that('check_if_there_are_na works',{
  #dataset with Na
  test_bt <- load_testdata('test_bt')
  test_bt_na1 <- test_bt
  test_bt_na1$y[4]<-NA

  test_btscores <- load_testdata('test_btscores')
  test_btscores_na1 <- test_btscores
  test_btscores_na1$score0[4]<-NA
  test_btscores_na1$score1[6]<-NA

  expect_true(check_if_there_are_na(d=test_btscores_na1,
                                    player0='player0',
                                    player1='player1',
                                    player0_score='score0',
                                    player1_score='score1',
                                    result_column=NULL))

  expect_true(check_if_there_are_na(d=test_bt_na1,
                                    player0='player0',
                                    player1='player1',
                                    result_column='y'))

  expect_false(check_if_there_are_na(d=test_btscores,
                                     player0='player0',
                                     player1='player1',
                                     player0_score='score0',
                                     player1_score='score1',
                                     result_column=NULL))

  expect_false(check_if_there_are_na(d=test_bt,
                                     player0='player0',
                                     player1='player1',
                                     result_column='y'))
})


test_that('check_numeric_predictor_matrix works',{
  m1<-as.matrix(data.frame(Pred1=c(2.3,1.4,4.2),
                           Pred2=c(-3.2,0.5,-2.1),
                           Pred3=c(0.01,0.04,0.02),
                           Pred4=c(-0.5,-0.2,-0.3)))

  m2<-as.matrix(data.frame(Pred1=c(2.3,1.4,4.2),
                           Pred2=c(-3.2,0.5,-2.1),
                           Pred3=c(0.01,'a',0.02),
                           Pred4=c(-0.5,-0.2,-0.3)))

  m3<-as.matrix(data.frame(Pred1=c(2.3,1.4,4.2),
                           Pred2=c(-3.2,0.5,-2.1),
                           Pred3=c(0.01,0,0.02),
                           Pred4=c(-0.5,-0.2,NA)))

  m4<-as.matrix(data.frame(Pred1=c(2.3,1.4,4.2),
                           Pred2=c(-3.2,0.5,-2.1),
                           Pred3=c(0.01,0,0.02),
                           Pred4=c(TRUE,-0.2,2)))

  m5<-as.matrix(data.frame(Pred1=c(2.3,1.4,4.2),
                           Pred2=c(-3.2,FALSE,-2.1),
                           Pred3=c(0.01,0,0.02),
                           Pred4=c(2,-0.2,2)))

  expect_true(check_numeric_predictor_matrix(m1))
  expect_false(check_numeric_predictor_matrix(m2))
  expect_false(check_numeric_predictor_matrix(m3))
  expect_true(check_numeric_predictor_matrix(m4))
  expect_equal(m4[[1,4]],1)
  expect_true(check_numeric_predictor_matrix(m5))
  expect_equal(m5[[2,2]],0)

})

test_that('check_predictors_df_contains_all_players works',{
  test_predictors1<-tibble::tribble(~Player, ~Pred1, ~Pred2, ~Pred3, ~Pred4,
                                    'A', 2.3, -3.2, 0.01, -1/2,
                                    'C', 4.2, -2.1, 0.02, -0.3,
                                    'B', 1.4, 0.5, 0.04, -0.2)

  test_predictors2<-tibble::tribble(~Player, ~Pred1, ~Pred2, ~Pred3, ~Pred4,
                                    'A', 2.3, -3.2, 0.01, -1/2,
                                    'C', 4.2, -2.1, 0.02, -0.3,
                                    'D', 1.4, 0.5, 0.04, -0.2)

  test_predictors3<-tibble::tribble(~Player, ~Pred1, ~Pred2, ~Pred3, ~Pred4,
                                    'A', 2.3, -3.2, 0.01, -1/2,
                                    'C', 4.2, -2.1, 0.02, -0.3,
                                    'D', 1.4, 0.5, 0.04, -0.2,
                                    'D', 1.4, 0.5, 2, -0.2)

  test_predictors4<-tibble::tribble(~Player, ~Pred1, ~Pred2, ~Pred3, ~Pred4,
                                    'A', 2.3, -3.2, 0.01, -1/2,
                                    'C', 4.2, -2.1, 0.02, -0.3,
                                    'B', 1.4, 0.5, 0.04, -0.2,
                                    'D', 1.4, 0.5, 2, -0.2)


  lookup_table<-data.frame(Names=c('A','B','C'), Index=c(1,2,3))

  expect_true(check_predictors_df_contains_all_players(test_predictors1,lookup_table))
  expect_false(check_predictors_df_contains_all_players(test_predictors2,lookup_table))
  expect_false(check_predictors_df_contains_all_players(test_predictors3,lookup_table))
  expect_false(check_predictors_df_contains_all_players(test_predictors4,lookup_table))
})

