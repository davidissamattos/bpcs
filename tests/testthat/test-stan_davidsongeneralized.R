test_that("bpc returns a bpc object the davidsongeneralized model", {
  skip_on_cran()
  test_davidson <- load_testdata('test_davidson')
  test_predictors <- load_testdata('test_predictors')
  m1 <- bpc(
    data = test_davidson,
    player0 = 'player0',
    player1 = 'player1',
    result_column = 'y',
    model_type = 'davidson-generalized',
    predictors = test_predictors,
    solve_ties = 'none',
    iter = 1000,
    warmup = 300,
    show_chain_messages = F,
    seed=8484
  )


  expect_s3_class(m1, 'bpc')
  expect_no_error(summary(m1))

})
