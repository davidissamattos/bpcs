test_that("create_index_lookuptable works with datasets", {
  test_bt<-load_testdata('test_bt')

  t_test_bt<- as.data.frame(tibble::tribble(~Names, ~Index,
                                            'A', 1,
                                            'B', 2,
                                            'C', 3,))

  expect_equal(create_index_lookuptable(test_bt, player0='player0', player1='player1'), t_test_bt)

})

test_that("create_index_lookuptable works with numbers", {
  number_in_order <- tibble::tribble(~player0, ~player1,
                                     1, 3,
                                     2,3,
                                     3,4)

  number_out_order <- tibble::tribble(~player0, ~player1,
                                      3, 1,
                                      4,3,
                                      1,4,
                                      5,2)

  t_number_in_order<- as.data.frame(tibble::tribble(~Names, ~Index,
                                                    1, 1,
                                                    2, 2,
                                                    3, 3,
                                                    4, 4))
  t_number_out_order<- as.data.frame(tibble::tribble(~Names, ~Index,
                                                     3, 1,
                                                     4, 2,
                                                     1, 3,
                                                     5, 4,
                                                     2, 5))

  expect_equal(create_index_lookuptable(number_in_order, player0='player0', player1='player1'), t_number_in_order)
  expect_equal(create_index_lookuptable(number_out_order, player0='player0', player1='player1'), t_number_out_order)
})

test_that("create_index works", {
  test_bt<-load_testdata('test_bt')
  t_test_bt<- as.data.frame(tibble::tribble(~player0, ~player1, ~y, ~player0_index, ~player1_index,
                                            'A', 'B', 0, 1, 2,
                                            'A', 'B', 0, 1, 2,
                                            'A', 'B', 1, 1, 2,
                                            'A', 'C', 0, 1, 3,
                                            'A', 'C', 0, 1, 3,
                                            'A', 'C', 0, 1, 3,
                                            'B', 'C', 0, 2, 3,
                                            'B', 'C', 0, 2, 3,
                                            'B', 'C', 1, 2, 3))
  expect_equal(create_index(test_bt, player0='player0', player1='player1'), t_test_bt)
})



test_that('replace_parameter_index_with_names works',{
  test_bt<-load_testdata('test_bt')
  data<-data.frame(v=  c('lambda[1]','lambda[2]','lambda[3]'))
  lookup_table<-create_index_lookuptable(test_bt,player0 = 'player0',player1 = 'player1')
  new_data <- data.frame(v=c('lambda[A]', 'lambda[B]', 'lambda[C]'))

  expect_equal(replace_parameter_index_with_names(data,'v','lambda',lookup_table),new_data)
})

test_that('create_array_of_par_names works',{
  test_bt<-load_testdata('test_bt')
  test_btU<-load_testdata('test_btU')
  lookup_table<-create_index_lookuptable(test_bt, player0 = 'player0',player1 = 'player1')
  result <- c('lambda[A]', 'lambda[B]', 'lambda[C]')
  expect_equal(create_array_of_par_names(par='lambda',lookup_table),result)

  lookup_table2<-create_index_lookuptable(test_btU, player0 = 'player0',player1 = 'player1')
  cluster_lookup_table2<-create_index_cluster_lookuptable(test_btU, cluster='cluster')
  result2 <- c('U[A,c1]', 'U[B,c1]', 'U[C,c1]','U[A,c2]', 'U[B,c2]', 'U[C,c2]','U[A,c3]', 'U[B,c3]', 'U[C,c3]','U[A,c4]', 'U[B,c4]', 'U[C,c4]')
  expect_equal(create_array_of_par_names(par='U',lookup_table=lookup_table2, cluster_lookup_table = cluster_lookup_table2),result2)

})


test_that('create_predictor_matrix_with_player_lookup_table works',{
  test_predictors<-load_testdata('test_predictors')
  result<-as.matrix(data.frame(Pred1=c(2.3,1.4,4.2),
                     Pred2=c(-3.2,0.5,-2.1),
                     Pred3=c(0.01,0.04,0.02),
                     Pred4=c(-0.5,-0.2,-0.3)))
  predictor_all_columns<-colnames(test_predictors)
  predictors_columns <- predictor_all_columns[2:length(predictor_all_columns)]
  player_column <- predictor_all_columns[1]
  lookup_table<-data.frame(Names=c('A','B','C'), Index=c(1,2,3))
  pred_matrix<-create_predictor_matrix_with_player_lookup_table(d=test_predictors,
                                                                player=player_column,
                                                                predictors_columns=predictors_columns,
                                                                lookup_table=lookup_table)
  expect_equal(pred_matrix,result)

})

test_that('create_predictors_lookup_table works',{
  test_predictors<-load_testdata('test_predictors')
  result<-data.frame(Names=c('Pred1','Pred2','Pred3','Pred4'),
                     Index=c(1,2,3,4))
  predictor_all_columns<-colnames(test_predictors)
  predictors_columns <- predictor_all_columns[2:length(predictor_all_columns)]
  predictors_lookup_table<-create_predictors_lookup_table(predictors_columns)
  expect_equal(predictors_lookup_table,result)

})

test_that('create_index_predictors_with_lookup_table works',{
  test_predictors<-load_testdata('test_predictors')
  result<-cbind(test_predictors,player_index=c(1,3,2))

  predictor_all_columns<-colnames(test_predictors)
  predictors_columns <- predictor_all_columns[2:length(predictor_all_columns)]
  player_column <- predictor_all_columns[1]
  lookup_table<-data.frame(Names=c('A','B','C'), Index=c(1,2,3))
  predictors_with_indexes<-create_index_predictors_with_lookup_table(test_predictors, player=player_column, lookup_table=lookup_table)
  expect_equal(predictors_with_indexes,result)

})



