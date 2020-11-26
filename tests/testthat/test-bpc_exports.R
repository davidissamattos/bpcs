test_that("get_stanfit works", {
  skip_on_cran()
  test_bt<-load_testdata("test_bt")
  m<-bpc(data=test_bt,
         player0 = 'player0',
         player1 = 'player1',
         result_column = 'y',
         model_type='bt',
         solve_ties='random',
         win_score = 'higher',
         show_chain_messages=F)
  expect_true(is(get_stanfit(m), 'stanfit'))
})

test_that("get_sample_posterior works", {
  skip_on_cran()
  test_bt<-load_testdata("test_bt")
  m<-bpc(data=test_bt,
      player0 = 'player0',
      player1 = 'player1',
      result_column = 'y',
      model_type='bt',
      solve_ties='random',
      win_score = 'higher',
      show_chain_messages=F)
  post<- get_sample_posterior(m, par = 'lambda', n=1000)
  expect_equal(ncol(post), 3)
  expect_equal(nrow(post), 1000)
  expect_equal(colnames(post), c('lambda[A]', 'lambda[B]', 'lambda[C]'))
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
