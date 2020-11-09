test_that("expand_aggregated_data works", {
  df1<- tibble::tribble(~player0, ~player1, ~wins0, ~wins1,~cluster,
                       'A','B',4, 3, 'c1')

  df1_result<- as.data.frame(tibble::tribble(~player0, ~player1, ~y,~cluster, ~rowid,
                               'A','B', 0, 'c1', 1,
                               'A','B', 0, 'c1', 2,
                               'A','B', 0, 'c1', 3,
                               'A','B', 0, 'c1', 4,
                               'A','B', 1, 'c1', 5,
                               'A','B', 1, 'c1', 6,
                               'A','B', 1, 'c1', 7))

  df2<- as.data.frame(tibble::tribble(~player0, ~player1, ~wins0, ~wins1,~cluster1,~cluster2,
                        'A','B',4, 3, 'c1', 'a1',
                        'A','C',1, 2, 'c2', 'a2'))

  df2_result<- as.data.frame(tibble::tribble(~player0, ~player1, ~y,~cluster1, ~cluster2 ,~rowid,
                               'A','B', 0, 'c1','a1', 1,
                               'A','B', 0, 'c1','a1', 2,
                               'A','B', 0, 'c1','a1', 3,
                               'A','B', 0, 'c1','a1', 4,
                               'A','B', 1, 'c1','a1', 5,
                               'A','B', 1, 'c1','a1', 6,
                               'A','B', 1, 'c1','a1', 7,
                               'A','C', 0, 'c2','a2', 8,
                               'A','C', 1, 'c2','a2', 9,
                               'A','C', 1, 'c2','a2', 10))

  expect_equal(expand_aggregated_data(df1,'player0', 'player1', 'wins0', 'wins1', keep=c('cluster')),df1_result)
  expect_equal(expand_aggregated_data(df2,'player0', 'player1', 'wins0', 'wins1', keep=c('cluster1','cluster2')), df2_result)


})
