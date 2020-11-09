test_that("bpc returns a bpc object the bt model", {
  m1<-bpc(data=test_bt,
          player0 = 'player0',
          player1 = 'player1',
          result_column = 'y',
          model_type='bt',
          solve_ties='random',
          win_score = 'higher',
          iter=1000,
          warmup=300,
          show_chain_messages=F)

  m2<-bpc(data=test_btscores,
          player0 = 'player0',
          player1 = 'player1',
          player0_score = 'score0',
          player1_score = 'score1',
          model_type='bt',
          solve_ties='random',
          win_score = 'higher',
          iter=1000,
          warmup=300,
          show_chain_messages=F)

  m_tennis<-bpc(data=tennis_agresti,
                player0 = 'player0',
                player1 = 'player1',
                result_column = 'y',
                model_type='bt',
                solve_ties='none',
                win_score = 'higher',
                iter=1000,
                warmup=300,
                show_chain_messages=F)

  expect_s3_class(m1,'bpc')
  expect_s3_class(m2,'bpc')
  expect_s3_class(m_tennis,'bpc')
})
