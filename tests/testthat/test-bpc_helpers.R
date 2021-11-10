test_that("compute_score works with btscores dataset", {
  test_btscores<-load_testdata('test_btscores')
  test_btscores_higher <- as.data.frame(tibble::tribble(~y,0,0,1,0,0,0,0,0,1))
  test_btscores_lower <- as.data.frame(tibble::tribble(~y,1,1,0,1,1,1,1,1,0))


  expect_equal(compute_scores(test_btscores, player0_score='score0', player1_score='score1', solve_ties='none', win_score='higher')$y, test_btscores_higher$y)
  expect_equal(compute_scores(test_btscores, player0_score='score0', player1_score='score1', solve_ties='none', win_score='lower')$y, test_btscores_lower$y)

})

test_that("compute_score works with davidsonscores dataset", {
  test_davidsonscores<-load_testdata('test_davidsonscores')
  test_davidsonscores_1 <- as.data.frame(tibble::tribble(~y,0,0,0,0,0,0,0,0,0))#0 win both ties
  test_davidsonscores_2 <- as.data.frame(tibble::tribble(~y,0,0,0,0,0,0,0,0,1))#0 wins first and 1 wins last
  test_davidsonscores_3 <- as.data.frame(tibble::tribble(~y,0,0,1,0,0,0,0,0,0))#1 wins first and 0 last
  test_davidsonscores_4 <- as.data.frame(tibble::tribble(~y,0,0,1,0,0,0,0,0,1))#1 wins both
  test_davidsonscores_5 <- as.data.frame(tibble::tribble(~y,0,0,0,0,0,0,0))#1 remove ties


  set.seed(2)#case 1
  expect_equal(compute_scores(test_davidsonscores, player0_score='score0', player1_score='score1',solve_ties='random', win_score='higher')$y, test_davidsonscores_1$y)

  set.seed(1)#case 2
  expect_equal(compute_scores(test_davidsonscores, player0_score='score0', player1_score='score1',solve_ties='random', win_score='higher')$y, test_davidsonscores_2$y)

  set.seed(4)#case 3
  expect_equal(compute_scores(test_davidsonscores, player0_score='score0', player1_score='score1',solve_ties='random', win_score='higher')$y, test_davidsonscores_3$y)

  set.seed(55)#case 4
  expect_equal(compute_scores(test_davidsonscores, player0_score='score0', player1_score='score1',solve_ties='random', win_score='higher')$y, test_davidsonscores_4$y)

  #case 5
  expect_equal(compute_scores(test_davidsonscores, player0_score='score0', player1_score='score1',solve_ties='remove', win_score='higher')$y, test_davidsonscores_5$y)


})


test_that('compute_ties works',{
  v1 <- data.frame(results=c(1,0,2,0,0,1))
  v2 <- data.frame(results=c(1,1,2,2,0,1))
  v3 <- data.frame(results=c(1,1,0,0,0,1))
  rv1 <- data.frame(ties=c(0,0,1,0,0,0))
  rv2 <- data.frame(ties=c(0,0,1,1,0,0))
  rv3 <- data.frame(ties=c(0,0,0,0,0,0))

  expect_equal(compute_ties(v1,'results')$ties, rv1$ties)
  expect_equal(compute_ties(v2,'results')$ties, rv2$ties)
  expect_equal(compute_ties(v3,'results')$ties, rv3$ties)
})


test_that('fix_ties works',{
  old_state <- get_rand_state() #saving seed state

  test_davidson<-load_testdata('test_davidson')

  v_none <- test_davidson

  #four possibilities
  v_random1 <- test_davidson
  v_random1$y <- c(0, 0, 0, 0, 0, 0, 0, 0, 0)
  v_random2 <- test_davidson
  v_random2$y <- c(0, 0, 1, 0, 0, 0, 0, 0, 0)
  v_random3 <- test_davidson
  v_random3$y <- c(0, 0, 0, 0, 0, 0, 0, 0, 1)
  v_random4 <- test_davidson
  v_random4$y <- c(0, 0, 1, 0, 0, 0, 0, 0, 1)

  v_remove <- test_davidson
  v_remove <- v_remove[-c(3,9),]
  row.names(v_remove) <- c()


  expect_equal(fix_ties(test_davidson,'none'), v_none)
  set.seed(33)
  expect_equal(fix_ties(test_davidson,'random'), v_random4)
  set.seed(353)
  expect_equal(fix_ties(test_davidson,'random'), v_random2)
  set.seed(3)
  expect_equal(fix_ties(test_davidson,'random'), v_random3)
  set.seed(42)
  expect_equal(fix_ties(test_davidson,'random'), v_random1)
  expect_equal(fix_ties(test_davidson,'remove'), v_remove)

  on.exit(set_rand_state(old_state))
})


test_that('calculate_prob_from_vector works',{
  v1 <- c(1,0,2,0,0,1)
  v2 <- c(1,1,1,0,0,0)
  v3 <- c(1,1,1,1,1)
  v4 <- c(0,0,0,0)


  expect_equal(calculate_prob_from_vector(v1,1), 2/6)
  expect_equal(calculate_prob_from_vector(v1,0), 3/6)
  expect_equal(calculate_prob_from_vector(v1,2), 1/6)
  expect_equal(calculate_prob_from_vector(v2,1), 3/6)
  expect_equal(calculate_prob_from_vector(v2,0), 3/6)
  expect_equal(calculate_prob_from_vector(v2,2), 0)
  expect_equal(calculate_prob_from_vector(v3,1), 1)
  expect_equal(calculate_prob_from_vector(v3,0), 0)
  expect_equal(calculate_prob_from_vector(v3,2), 0)
  expect_equal(calculate_prob_from_vector(v4,1), 0)
  expect_equal(calculate_prob_from_vector(v4,0), 1)
  expect_equal(calculate_prob_from_vector(v4,2), 0)
})

