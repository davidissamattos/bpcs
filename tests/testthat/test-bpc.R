test_that("Input errors are caught in bpc", {
  #missing either player scores and the result column
  #mising player0_score and result column
  test_btscores<-load_testdata("test_btscores")


  expect_error(bpc(data=test_btscores,
                   player0 = 'player0',
                   player1 = 'player1',
                   player1_score = 'score1',
                   model_type='bt',
                   solve_ties='random',
                   win_score = 'higher'))
  #mising player1_score and result column
  expect_error(bpc(data=test_btscores,
                    player0 = 'player0',
                    player1 = 'player1',
                    player1_score = 'score0',
                    model_type='bt',
                    solve_ties='random',
                    win_score = 'higher'))
  #missing both scores and result column
  expect_error(bpc(data=test_btscores,
                    player0 = 'player0',
                    player1 = 'player1',
                    model_type='bt',
                    solve_ties='random',
                    win_score = 'higher'))

  # input is not data frame or tibble # weird input for example
  expect_error(bpc(data=c(1,1,2),
                   player0 = 'player0',
                   player1 = 'player1',
                   results_column='y',
                   model_type='bt',
                   solve_ties='random',
                   win_score = 'higher'))



})


test_that("Input warnings are caught in bpc", {
  test_davidson<-load_testdata("test_davidson")
  expect_warning(bpc(data=test_davidson,
                   player0 = 'player0',
                   player1 = 'player1',
                   result_column = 'y',
                   model_type='davidson',
                   solve_ties='random',
                   win_score = 'higher',
                   iter=1000,
                   warmup=300,
                   show_chain_messages=F))
})

test_that('if there are ties AND solte_ties is none AND model is not davidson gives error',{
  test_davidson<-load_testdata("test_davidson")
  expect_error(bpc(data=test_davidson,#there are ties here
                   player0 = 'player0',
                   player1 = 'player1',
                   results_column = 'y',
                   model_type='bt', #model is not davidson
                   solve_ties='none', #method is none
                   win_score = 'higher'))
})


test_that('if has z_player1 column but not the correct model gives error',{
  test_btorder<-load_testdata("test_btorder")
  expect_error(bpc(data=test_btorder,#there are ties here
                   player0 = 'player0',
                   player1 = 'player1',
                   result_column = 'y',
                   z_player1 = 'y',
                   model_type='bt', #model is not btordereffect
                   solve_ties='none',
                   win_score = 'higher'))
})





