test_that("bpc returns a bpc object the btU model", {
  skip_on_cran()
  test_btU <- load_testdata('test_btU')
  m1 <- bpc(
    data = test_btU,
    player0 = 'player0',
    player1 = 'player1',
    result_column = 'y',
    cluster = c('cluster'),
    model_type = 'bt-U',
    solve_ties = 'random',
    win_score = 'higher',
    iter = 2000,
    warmup = 500,
    show_chain_messages = F,
    seed=8484
  )
  expect_s3_class(m1, 'bpc')
  expect_no_error(summary(m1))
  expect_no_error(posterior_predictive(m1))
  expect_no_error(get_probabilities_df(m1, model_type = 'bt'))

  # Sys.sleep(5)
  m2 <- bpc(
    data = test_btU,
    player0 = 'player0',
    player1 = 'player1',
    result_column = 'y',
    cluster = c('cluster', 'cluster2'),
    model_type = 'bt-U',
    solve_ties = 'random',
    win_score = 'higher',
    iter = 2000,
    warmup = 500,
    show_chain_messages = F,
    seed=8484
  )
  expect_s3_class(m2, 'bpc')
  expect_no_error(summary(m2))

  expect_no_error(posterior_predictive(m2))
  expect_no_error(get_probabilities_df(m2, model_type = 'bt'))

  # Sys.sleep(5)
  m3 <- bpc(
    data = test_btU,
    player0 = 'player0',
    player1 = 'player1',
    result_column = 'y',
    cluster = c('cluster', 'cluster2','cluster3'),
    model_type = 'bt-U',
    solve_ties = 'random',
    win_score = 'higher',
    iter = 2000,
    warmup = 500,
    show_chain_messages = F,
    seed=8484
  )
  # Sys.sleep(5)
  expect_s3_class(m3, 'bpc')
  expect_no_error(summary(m3))
  expect_no_error(posterior_predictive(m3))
  expect_no_error(get_probabilities_df(m3, model_type = 'bt'))
})
