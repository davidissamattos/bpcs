test_that("bpc returns a bpc object the bt model", {
  skip_on_cran()
  test_bt <- load_testdata('test_bt')

  m1 <- bpc(
    data = test_bt,
    player0 = 'player0',
    player1 = 'player1',
    result_column = 'y',
    model_type = 'bt',
    solve_ties = 'random',
    win_score = 'higher',
    iter = 1000,
    warmup = 300,
    show_chain_messages = F,
    seed = 8484
  )
  # Sys.sleep(5)
  test_btscores <- load_testdata('test_btscores')
  m2 <- bpc(
    data = test_btscores,
    player0 = 'player0',
    player1 = 'player1',
    player0_score = 'score0',
    player1_score = 'score1',
    model_type = 'bt',
    solve_ties = 'random',
    win_score = 'higher',
    iter = 1000,
    warmup = 300,
    show_chain_messages = F,
    seed = 8484
  )

  expect_s3_class(m1, 'bpc')
  expect_s3_class(m2, 'bpc')
  expect_no_error(summary(m1))
  expect_no_error(summary(m2))
  expect_no_error(check_convergence_diagnostics(m1))
  expect_no_error(check_convergence_diagnostics(m2))


  # testing with solve ties

  dt <- dplyr::bind_rows(
    tennis_agresti,
    tibble::tibble(player0 = "Seles", player1 = "Graf", y = 2, id = 47)
  )

  m3 <- bpc(data = dt,
            player0 = 'player0',
            player1 = 'player1',
            result_column = 'y',
            model_type = 'bt',
            solve_ties = 'random',
            show_chain_messages = T)
  m4 <- bpc(data = dt,
            player0 = 'player0',
            player1 = 'player1',
            result_column = 'y',
            model_type = 'bt',
            solve_ties = 'remove',
            show_chain_messages = T)
  expect_s3_class(m3, 'bpc')
  expect_s3_class(m4, 'bpc')
  expect_no_error(summary(m3))
  expect_no_error(summary(m4))
  expect_no_error(check_convergence_diagnostics(m3))
  expect_no_error(check_convergence_diagnostics(m4))



})
