test_that("get_stanfit works", {
  m_citations<-bpc(data=citations_agresti,
                   player0 = 'journal1',
                   player1 = 'journal2',
                   player0_score = 'score1',
                   player1_score = 'score2',
                   model_type='bradleyterry',
                   solve_ties='random',
                   win_score = 'higher',
                   show_chain_messages=F)
  expect_true(is(get_stanfit(m_citations), 'stanfit'))
})

test_that("sample_posterior works", {
  m_citations<-bpc(data=citations_agresti,
                   player0 = 'journal1',
                   player1 = 'journal2',
                   player0_score = 'score1',
                   player1_score = 'score2',
                   model_type='bradleyterry',
                   solve_ties='random',
                   win_score = 'higher',
                   show_chain_messages=F)
  post<- sample_posterior(m_citations, par = 'lambda', n=1000)
  expect_equal(ncol(post), 4)
  expect_equal(nrow(post), 1000)
  expect_equal(colnames(post), c('lambda_Biometrika', 'lambda_CommStat', 'lambda_JASA', 'lambda_JRSSB'))

})
#
#
#
# test_that("get_hpdi_parameters works", {
#
#
# })
#
#
# test_that("rank_parameters works", {
#
#
# })
#
# test_that("get_probabilities works", {
#
#
# })
#
#
# test_that("get_loo works", {
#
#
# })
#
# test_that("get_waic works", {
#
#
# })
