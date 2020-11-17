test_that("bpc returns a bpc object the btordereffect model", {
  test_btorder<-load_testdata('test_btorder')
  m1<-bpc(data=test_btorder,
          player0 = 'player0',
          player1 = 'player1',
          result_column = 'y',
          z_player1='z1',
          model_type='btordereffect',
          solve_ties='random',
          win_score = 'higher',
          iter=1000,
          warmup=300,
          show_chain_messages=F)

  expect_s3_class(m1,'bpc')

})
