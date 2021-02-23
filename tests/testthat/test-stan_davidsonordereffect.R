test_that("bpc returns a bpc object the davidsonordereffect model", {
  skip_on_cran()
  test_davidsonorder <- load_testdata('test_davidsonorder')
  m1 <- bpc(
    data = test_davidsonorder,
    player0 = 'player0',
    player1 = 'player1',
    result_column = 'y',
    z_player1 = 'z1',
    model_type = 'davidson-ordereffect',
    solve_ties = 'none',
    win_score = 'higher',
    iter = 1000,
    warmup = 300,
    show_chain_messages = F,
    seed = 8484
  )
  # Sys.sleep(5)
  expect_s3_class(m1, 'bpc')
  expect_no_error(summary(m1))
})
