test_that("bpc returns a bpc object the bt model", {
  skip_on_cran()
  test_bt_subject <- load_testdata('test_bt_subject')
  m1 <- bpc(
    data = test_bt_subject,
    player0 = 'player0',
    player1 = 'player1',
    result_column = 'y',
    model_type = 'bt-subjectpredictors',
    subject_predictors = c('SPred1', 'SPred2', 'SPred3'),
    solve_ties = 'random',
    win_score = 'higher',
    iter = 1000,
    warmup = 300,
    show_chain_messages = F,
    seed = 8484
  )
  expect_s3_class(m1, 'bpc')
  expect_no_error(summary(m1))

})
