test_that("bpc returns a bpc object the btU model", {
  test_btU<-load_testdata('test_btU')
  m1<-bpc(data=test_btU,
          player0 = 'player0',
          player1 = 'player1',
          result_column = 'y',
          cluster = 'cluster',
          model_type='btU',
          solve_ties='random',
          win_score = 'higher',
          iter=2000,
          warmup=500,
          show_chain_messages=F)

  expect_s3_class(m1,'bpc')
  expect_no_error(summary(m1))
})
