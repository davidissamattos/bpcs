test_that("create_index_lookuptable works with datasets", {
  t_citations_agresti<- as.data.frame(tibble::tribble(~Names, ~Index,
                                         'Biometrika', 1,
                                         'CommStat', 2,
                                         'JASA', 3,
                                         'JRSSB', 4))
  t_tennis_agresti<- as.data.frame(tibble::tribble(~Names, ~Index,
                                         'Seles', 1,
                                         'Graf', 2,
                                         'Sabatini', 3,
                                         'Navratilova', 4,
                                          'Sanchez', 5))
  expect_equal(create_index_lookuptable(citations_agresti, player0='journal1', player1='journal2'), t_citations_agresti)
  expect_equal(create_index_lookuptable(tennis_agresti, player0='player1', player1='player2'), t_tennis_agresti)
})

test_that("create_index_lookuptable works with numbers", {
  number_in_order <- tibble::tribble(~player1, ~player2,
                                       1, 3,
                                       2,3,
                                       3,4)

  number_out_order <- tibble::tribble(~player1, ~player2,
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

  expect_equal(create_index_lookuptable(number_in_order, player0='player1', player1='player2'), t_number_in_order)
  expect_equal(create_index_lookuptable(number_out_order, player0='player1', player1='player2'), t_number_out_order)
})

test_that("create_index works with datasets", {
  t_citations_agresti<- as.data.frame(tibble::tribble(~journal1, ~journal2, ~score1, ~score2, ~player0_index, ~player1_index,
                  'Biometrika', 'CommStat', 730, 33, 1, 2,
                  'Biometrika', 'JASA', 498, 320, 1, 3,
                  'Biometrika', 'JRSSB', 221, 284, 1, 4,
                  'CommStat', 'JASA',68, 813, 2, 3,
                  'CommStat', 'JRSSB',17, 276, 2, 4,
                  'JASA', 'JRSSB', 142, 325, 3, 4 ))

  t_tennis_agresti <- as.data.frame(tibble::tribble(~player1, ~player2, ~wins_player1, ~wins_player2, ~player0_index, ~player1_index,
                                    'Seles', 'Graf', 2, 3, 1, 2,
                                    'Seles', 'Sabatini', 1, 0, 1, 3,
                                    'Seles', 'Navratilova', 3, 3, 1, 4,
                                    'Seles', 'Sanchez', 2, 0, 1, 5,
                                    'Graf', 'Sabatini', 6, 3, 2, 3,
                                    'Graf', 'Navratilova', 3, 0, 2, 4,
                                    'Graf', 'Sanchez', 7, 1, 2, 5,
                                    'Sabatini', 'Navratilova', 1, 2, 3, 4,
                                    'Sabatini', 'Sanchez', 3, 2, 3, 5,
                                    'Navratilova', 'Sanchez',3, 1, 4, 5)
  )
  expect_equal(create_index(citations_agresti, player0='journal1', player1='journal2'), t_citations_agresti)
  expect_equal(create_index(tennis_agresti, player0='player1', player1='player2'), t_tennis_agresti)
  })


test_that("compute_score works with datasets", {
  t_citations_agresti<- as.data.frame(tibble::tribble(~y, 0,0,1,1,1,1))
  t_citations_agresti_lower<- as.data.frame(tibble::tribble(~y, 1,1,0,0,0,0))

  t_tennis_agresti <- as.data.frame(tibble::tribble(~y,1,0,-1,0,0,0,0,1,0,0))
  t_tennis_agresti_remove <- as.data.frame(tibble::tribble(~y,1,0,0,0,0,0,1,0,0))
  t_tennis_agresti_0won <- as.data.frame(tibble::tribble(~y,1,0,0,0,0,0,0,1,0,0))
  t_tennis_agresti_1won <- as.data.frame(tibble::tribble(~y,1,0,1,0,0,0,0,1,0,0))


  expect_equal(compute_scores(citations_agresti, player0_score='score1', player1_score='score2', solve_ties='none', win_score='higher')$y, t_citations_agresti$y)
  expect_equal(compute_scores(citations_agresti, player0_score='score1', player1_score='score2', solve_ties='none', win_score='lower')$y, t_citations_agresti_lower$y)


  expect_equal(compute_scores(tennis_agresti, player0_score='wins_player1', player1_score='wins_player2',solve_ties='none', win_score='higher')$y, t_tennis_agresti$y)
  expect_equal(compute_scores(tennis_agresti, player0_score='wins_player1', player1_score='wins_player2',solve_ties='remove', win_score='higher')$y, t_tennis_agresti_remove$y)

  set.seed(1)#0 won in the draw
  expect_equal(compute_scores(tennis_agresti, player0_score='wins_player1', player1_score='wins_player2',solve_ties='random', win_score='higher')$y, t_tennis_agresti_0won$y)

  set.seed(4)#1 won in the draw
  expect_equal(compute_scores(tennis_agresti, player0_score='wins_player1', player1_score='wins_player2',solve_ties='random', win_score='higher')$y, t_tennis_agresti_1won$y)

})

test_that('check_result_column works',{
  v1 <- data.frame(results=c(1,0,-1,0,0,1))#true
  v2 <- data.frame(results=c(1,1.2,-1,0,0,1))#false
  v3 <- data.frame(results=c(1,2,-1,0,0,1))#false
  v4 <- data.frame(results=c(1,1,-1,0,0,1,'a'))#false
  expect_true(check_result_column(v1$results))
  expect_false(check_result_column(v2$results))
  expect_false(check_result_column(v3$results))
  expect_false(check_result_column(v4
                                   $results))
})

test_that('check_if_there_are_ties works',{
  v1 <- data.frame(results=c(1,0,-1,0,0,1))#true
  v2 <- data.frame(results=c(1,1,1,0,0,1))#false
  v3 <- data.frame(results=c(1,1,0,0,1))#false
  expect_true(check_if_there_are_ties(v1$results))
  expect_false(check_if_there_are_ties(v2$results))
  expect_false(check_if_there_are_ties(v3$results))
})

test_that('check_if_there_are_na works',{
  #dataset with Na
  citations_agresti_na1 <- tibble::tribble(~journal1, ~journal2, ~score1, ~score2,
                                       'Biometrika', 'CommStat', 730, 33,
                                       'Biometrika', 'JASA', NA, 320,
                                       'Biometrika', 'JRSSB', 221, 284,
                                       'CommStat', 'JASA',68, 813,
                                       'CommStat', 'JRSSB',17, 276,
                                       'JASA', 'JRSSB', 142, 325)
  citations_agresti_na2 <- tibble::tribble(~journal1, ~journal2, ~score1, ~score2,
                                           'Biometrika', 'CommStat', 730, 33,
                                           'Biometrika', 'JASA', NA, 320,
                                           'Biometrika', 'JRSSB', 221, 284,
                                           'CommStat', 'JASA',68, 813,
                                           'CommStat', 'JRSSB',NA, 276,
                                           'JASA', 'JRSSB', 142, NA)

  expect_true(check_if_there_are_na(d=citations_agresti_na1,
                                    player0='journal1',
                                    player1='journal2',
                                    player0_score='score1',
                                    player1_score='score2',
                                    result_column=NULL))
  expect_true(check_if_there_are_na(d=citations_agresti_na2,
                                    player0='journal1',
                                    player1='journal2',
                                    player0_score='score1',
                                    player1_score='score2',
                                    result_column=NULL))

  expect_false(check_if_there_are_na(d=citations_agresti,
                                    player0='journal1',
                                    player1='journal2',
                                    player0_score='score1',
                                    player1_score='score2',
                                    result_column=NULL))
})


test_that('replace_parameter_index_with_names works',{
  data<-data.frame(v=  c('lambda[1]','lambda[2]','lambda[3]','lambda[4]'))
  lookup_table<-create_index_lookuptable(citations_agresti,player0 = 'journal1','journal2')
  new_data <- data.frame(v=c('lambda_Biometrika', 'lambda_CommStat', 'lambda_JASA', 'lambda_JRSSB'))

  expect_equal(replace_parameter_index_with_names(data,'v','lambda',lookup_table),new_data)
})
