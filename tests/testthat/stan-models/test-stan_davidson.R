test_that("bpc returns a bpc object with datasets using the davidson model", {
  m_ties<-bpc(data=test_davidson,
              player0 = 'player0',
              player1 = 'player1',
              result_column = 'y',
              solve_ties = 'none',
              model_type='davidson',
              iter=1000,
              warmup=300,
              show_chain_messages=F)

  expect_s3_class(m_ties,'bpc')
})
