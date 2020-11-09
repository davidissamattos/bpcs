test_that("get_stanfit works", {
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

test_that("sample_posterior works", {
  m<-bpc(data=test_bt,
      player0 = 'player0',
      player1 = 'player1',
      result_column = 'y',
      model_type='bt',
      solve_ties='random',
      win_score = 'higher',
      show_chain_messages=F)
  post<- sample_posterior(m, par = 'lambda', n=1000)
  expect_equal(ncol(post), 3)
  expect_equal(nrow(post), 1000)
  expect_equal(colnames(post), c('lambda[A]', 'lambda[B]', 'lambda[C]'))
})
