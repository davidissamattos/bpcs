test_that("compute_score works with btscores dataset", {
  test_btscores_higher <- as.data.frame(tibble::tribble(~y,0,0,1,0,0,0,0,0,1))
  test_btscores_lower <- as.data.frame(tibble::tribble(~y,1,1,0,1,1,1,1,1,0))


  expect_equal(compute_scores(test_btscores, player0_score='score0', player1_score='score1', solve_ties='none', win_score='higher')$y, test_btscores_higher$y)
  expect_equal(compute_scores(test_btscores, player0_score='score0', player1_score='score1', solve_ties='none', win_score='lower')$y, test_btscores_lower$y)

})

test_that("compute_score works with davidsonscores dataset", {
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


test_that("Logit test if x is in bounds", {
  expect_error(logit(-1),'Error!')
  expect_error(logit(10),'Error!')
})

test_that('Known logit values', {
  expect_equal(logit(0.5),0)
  expect_equal(logit(1),Inf)
  expect_equal(logit(0),-Inf)
})


test_that('Known inv logit values', {
  expect_lt(inv_logit(5)-0.9933071, 0.001)
  expect_lt(inv_logit(-5)-0.006692851,  0.001)
  expect_lt(inv_logit(0)-0.5, 0.001)
})
