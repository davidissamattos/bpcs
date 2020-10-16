test_that("Input errors are caught in bpc", {
 #missing either player scores and the result column
  #mising player0_score and result column
 expect_error(bpc(data=citations_agresti,
                  player0 = 'journal1',
                  player1 = 'journal2',
                  player1_score = 'score2',
                  model_type='bradleyterry',
                  solve_ties='random',
                  win_score = 'higher'))
  #mising player1_score and result column
  expect_error(bpc(data=citations_agresti,
                   player0 = 'journal1',
                   player1 = 'journal2',
                   player0_score = 'score1',
                   model_type='bradleyterry',
                   solve_ties='random',
                   win_score = 'higher'))
  #missing both scores and result column
  expect_error(bpc(data=citations_agresti,
                   player0 = 'journal1',
                   player1 = 'journal2',
                   model_type='bradleyterry',
                   solve_ties='random',
                   win_score = 'higher'))

# input is not data frame or tibble # weird input for example
  expect_error(bpc(data=c(1,1,2),
                   player0 = 'journal1',
                   player1 = 'journal2',
                   model_type='bradleyterry',
                   solve_ties='random',
                   win_score = 'higher'))

})

test_that('if there are ties AND solte_ties is none AND model is not davidson gives error',{
  expect_error(bpc(data=tennis_agresti,#there are ties here
                   player0 = 'player1',
                   player1 = 'player2',
                   player0_score = 'wins_player1',
                   player1_score = 'wins_player2',
                   model_type='bradleyterry', #model is not davidson
                   solve_ties='none', #method is none
                   win_score = 'higher'))
          })




test_that("bpc returns a bpc object with datasets using the bradleyterry model", {
  m_citations<-bpc(data=citations_agresti,
                  player0 = 'journal1',
                  player1 = 'journal2',
                  player0_score = 'score1',
                  player1_score = 'score2',
                  model_type='bradleyterry',
                  solve_ties='random',
                  win_score = 'higher')

  m1_tennis<-bpc(data=tennis_agresti,
                               player0 = 'player1',
                               player1 = 'player2',
                               player0_score = 'wins_player1',
                               player1_score = 'wins_player2',
                               model_type='bradleyterry',
                               solve_ties='random',
                               win_score = 'higher')

  m2_tennis<-bpc(data=tennis_agresti,
                 player0 = 'player1',
                 player1 = 'player2',
                 player0_score = 'wins_player1',
                 player1_score = 'wins_player2',
                 model_type='bradleyterry',
                 solve_ties='remove',
                 win_score = 'higher')

  expect_s3_class(m_citations,'bpc')
  expect_s3_class(m1_tennis,'bpc')
  expect_s3_class(m2_tennis,'bpc')
})
