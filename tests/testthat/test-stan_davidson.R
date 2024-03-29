test_that("bpc returns a bpc object with datasets using the davidson model", {
  skip_on_cran()
  test_davidson <- load_testdata('test_davidson')
  m1 <- bpc(
    data = test_davidson,
    player0 = 'player0',
    player1 = 'player1',
    result_column = 'y',
    solve_ties = 'none',
    model_type = 'davidson',
    iter = 1000,
    warmup = 300,
    show_chain_messages = F,
    seed = 8484
  )
  # Sys.sleep(5)
  expect_s3_class(m1, 'bpc')
  expect_no_error(summary(m1))

  expect_no_error(posterior_predictive(m1))

  expect_no_error(get_probabilities_df(m1, model_type = 'davidson'))
})
