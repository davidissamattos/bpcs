test_that("bpc returns a bpc object the davidsonU model", {
  skip_on_cran()
  test_davidsonU <- load_testdata('test_davidsonU')
  m1 <- bpc(
    data = test_davidsonU,
    player0 = 'player0',
    player1 = 'player1',
    result_column = 'y',
    cluster = 'cluster',
    model_type = 'davidson-U',
    solve_ties = 'none',
    win_score = 'higher',
    iter = 1000,
    warmup = 300,
    show_chain_messages = F,
    seed=8484
  )

  expect_s3_class(m1, 'bpc')
  expect_no_error(summary(m1))
})
