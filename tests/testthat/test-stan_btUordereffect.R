test_that("bpc returns a bpc object the bt-U-ordereffect model", {
  skip_on_cran()
  test_btU <- load_testdata('test_btUordereffect')
  m1 <- bpc(
    data = test_btU,
    player0 = 'player0',
    player1 = 'player1',
    result_column = 'y',
    cluster = 'cluster',
    z_player1 = 'z1',
    model_type = 'bt-U-ordereffect',
    solve_ties = 'random',
    win_score = 'higher',
    iter = 2000,
    warmup = 600,
    show_chain_messages = F,
    seed = 8484
  )

  expect_s3_class(m1, 'bpc')
  expect_no_error(summary(m1))
})
