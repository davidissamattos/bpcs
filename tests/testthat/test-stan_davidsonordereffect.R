test_that("bpc returns a bpc object the davidsonordereffect model", {
  test_davidsonorder<-load_testdata('test_davidsonorder')
  m1<-bpc(data=test_davidsonorder,
          player0 = 'player0',
          player1 = 'player1',
          result_column = 'y',
          z_player1='z1',
          model_type='davidsonordereffect',
          solve_ties='none',
          win_score = 'higher',
          iter=1000,
          warmup=300,
          show_chain_messages=F)

  expect_s3_class(m1,'bpc')
  expect_no_error(summary(m1))
})
