test_that("bpc returns a bpc object the btgeneralized model", {
  test_bt<-load_testdata('test_bt')
  test_predictors<- load_testdata('test_predictors')
  m1<-bpc(data=test_bt,
          player0 = 'player0',
          player1 = 'player1',
          result_column = 'y',
          model_type='btgeneralized',
          predictors = test_predictors,
          solve_ties='none',
          iter=1000,
          warmup=300,
          show_chain_messages=F)


  expect_s3_class(m1,'bpc')
  expect_no_error(summary(m1))

})
