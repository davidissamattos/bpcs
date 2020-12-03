## code to prepare test datasets

#test sets for BT
test_bt<-tibble::tribble(~player0, ~player1, ~y,
                         'A', 'B', 0,
                         'A', 'B', 0,
                         'A', 'B', 1,
                         'A', 'C', 0,
                         'A', 'C', 0,
                         'A', 'C', 0,
                         'B', 'C', 0,
                         'B', 'C', 0,
                         'B', 'C', 1)
test_bt<-as.data.frame(test_bt)

test_btscores<-tibble::tribble(~player0, ~player1, ~score0, ~score1,
                         'A', 'B', 3, 1,
                         'A', 'B', 2, 0,
                         'A', 'B', 1, 2,
                         'A', 'C', 3, 0,
                         'A', 'C', 3, 2,
                         'A', 'C', 4, 3,
                         'B', 'C', 3, 2,
                         'B', 'C', 2, 1,
                         'B', 'C', 0, 1)
test_btscores<-as.data.frame(test_btscores)


### Test set Davidson

test_davidsonscores<-tibble::tribble(~player0, ~player1, ~score0, ~score1,
                               'A', 'B', 3, 1,
                               'A', 'B', 2, 0,
                               'A', 'B', 1, 1,
                               'A', 'C', 3, 0,
                               'A', 'C', 3, 2,
                               'A', 'C', 4, 3,
                               'B', 'C', 3, 2,
                               'B', 'C', 2, 1,
                               'B', 'C', 0, 0)
test_davidsonscores<-as.data.frame(test_davidsonscores)

test_davidson<-tibble::tribble(~player0, ~player1, ~y,
           'A', 'B', 0,
           'A', 'B', 0,
           'A', 'B', 2,
           'A', 'C', 0,
           'A', 'C', 0,
           'A', 'C', 0,
           'B', 'C', 0,
           'B', 'C', 0,
           'B', 'C', 2)
test_davidson<-as.data.frame(test_davidson)


# Test sets home advantage

test_btorder<-tibble::tribble(~player0, ~player1, ~y, ~z1,
                                   'A', 'B', 0, 1,
                                   'A', 'B', 0, 1,
                                   'A', 'B', 1, 0,
                                   'A', 'C', 0, 1,
                                   'A', 'C', 0, 1,
                                   'A', 'C', 0, 0,
                                   'B', 'C', 0, 0,
                                   'B', 'C', 0, 0,
                                   'B', 'C', 1, 0)
test_btorder<-as.data.frame(test_btorder)

test_davidsonorder<-tibble::tribble(~player0, ~player1, ~y, ~z1,
                               'A', 'B', 0, 1,
                               'A', 'B', 0, 1,
                               'A', 'B', 2, 0,
                               'A', 'C', 0, 1,
                               'A', 'C', 0, 1,
                               'A', 'C', 0, 0,
                               'B', 'C', 0, 0,
                               'B', 'C', 0, 0,
                               'B', 'C', 2, 0)
test_davidsonorder<-as.data.frame(test_davidsonorder)

# Test sets for random effects
## code to prepare test datasets
test_btU<-tibble::tribble(~player0, ~player1, ~y, ~cluster,
                         'A', 'B', 0, 'c1',
                         'A', 'B', 0, 'c1',
                         'A', 'B', 0, 'c1',
                         'A', 'C', 0, 'c1',
                         'A', 'C', 0, 'c1',
                         'A', 'C', 0, 'c1',
                         'B', 'C', 0, 'c1',
                         'B', 'C', 1, 'c1',
                         'B', 'C', 1, 'c1',
                         'A', 'B', 0, 'c2',
                         'A', 'B', 1, 'c2',
                         'A', 'B', 1, 'c2',
                         'A', 'C', 0, 'c2',
                         'A', 'C', 1, 'c2',
                         'A', 'C', 0, 'c2',
                         'B', 'C', 0, 'c2',
                         'B', 'C', 1, 'c2',
                         'B', 'C', 1, 'c2',
                         'A', 'B', 0, 'c3',
                         'A', 'B', 0, 'c3',
                         'A', 'B', 1, 'c3',
                         'A', 'C', 1, 'c3',
                         'A', 'C', 1, 'c3',
                         'A', 'C', 1, 'c3',
                         'B', 'C', 0, 'c3',
                         'B', 'C', 0, 'c3',
                         'B', 'C', 1, 'c3',
                         'A', 'B', 0, 'c4',
                         'A', 'B', 0, 'c4',
                         'A', 'B', 1, 'c4',
                         'A', 'C', 0, 'c4',
                         'A', 'C', 1, 'c4',
                         'A', 'C', 1, 'c4',
                         'B', 'C', 0, 'c4',
                         'B', 'C', 1, 'c4',
                         'B', 'C', 1, 'c4'
                         )

test_btU<-as.data.frame(test_btU)

test_davidsonU<-tibble::tribble(~player0, ~player1, ~y, ~cluster,
                          'A', 'B', 0, 'c1',
                          'A', 'B', 0, 'c1',
                          'A', 'B', 2, 'c1',
                          'A', 'C', 0, 'c1',
                          'A', 'C', 0, 'c1',
                          'A', 'C', 0, 'c1',
                          'B', 'C', 2, 'c1',
                          'B', 'C', 1, 'c1',
                          'B', 'C', 1, 'c1',
                          'A', 'B', 0, 'c2',
                          'A', 'B', 1, 'c2',
                          'A', 'B', 1, 'c2',
                          'A', 'C', 2, 'c2',
                          'A', 'C', 1, 'c2',
                          'A', 'C', 2, 'c2',
                          'B', 'C', 0, 'c2',
                          'B', 'C', 1, 'c2',
                          'B', 'C', 1, 'c2',
                          'A', 'B', 0, 'c3',
                          'A', 'B', 0, 'c3',
                          'A', 'B', 2, 'c3',
                          'A', 'C', 2, 'c3',
                          'A', 'C', 1, 'c3',
                          'A', 'C', 1, 'c3',
                          'B', 'C', 0, 'c3',
                          'B', 'C', 2, 'c3',
                          'B', 'C', 1, 'c3',
                          'A', 'B', 0, 'c4',
                          'A', 'B', 2, 'c4',
                          'A', 'B', 1, 'c4',
                          'A', 'C', 0, 'c4',
                          'A', 'C', 1, 'c4',
                          'A', 'C', 1, 'c4',
                          'B', 'C', 2, 'c4',
                          'B', 'C', 1, 'c4',
                          'B', 'C', 1, 'c4')
test_davidsonU<-as.data.frame(test_davidsonU)

test_predictors<-tibble::tribble(~Player, ~Pred1, ~Pred2, ~Pred3, ~Pred4,
                         'A', 2.3, -3.2, 0.01, -1/2,
                         'C', 4.2, -2.1, 0.02, -0.3,
                         'B', 1.4, 0.5, 0.04, -0.2)
test_predictors<-as.data.frame(test_predictors)





#### Some combinations
# Test sets for random effects
# Player 1 always have home advantage
test_btUordereffect<-tibble::tribble(~player0, ~player1, ~y, ~cluster, ~z1,
                          'A', 'B', 0, 'c1', 1,
                          'A', 'B', 0, 'c1', 1,
                          'A', 'B', 0, 'c1', 1,
                          'A', 'C', 0, 'c1', 1,
                          'A', 'C', 0, 'c1', 1,
                          'A', 'C', 0, 'c1', 1,
                          'B', 'C', 0, 'c1', 1,
                          'B', 'C', 1, 'c1', 1,
                          'B', 'C', 1, 'c1', 1,
                          'A', 'B', 0, 'c2', 1,
                          'A', 'B', 1, 'c2', 1,
                          'A', 'B', 1, 'c2', 1,
                          'A', 'C', 0, 'c2', 1,
                          'A', 'C', 1, 'c2', 1,
                          'A', 'C', 0, 'c2', 1,
                          'B', 'C', 0, 'c2', 1,
                          'B', 'C', 1, 'c2', 1,
                          'B', 'C', 1, 'c2', 1,
                          'A', 'B', 0, 'c3', 1,
                          'A', 'B', 0, 'c3', 1,
                          'A', 'B', 1, 'c3', 1,
                          'A', 'C', 1, 'c3', 1,
                          'A', 'C', 1, 'c3', 1,
                          'A', 'C', 1, 'c3', 1,
                          'B', 'C', 0, 'c3', 1,
                          'B', 'C', 0, 'c3', 1,
                          'B', 'C', 1, 'c3', 1,
                          'A', 'B', 0, 'c4', 1,
                          'A', 'B', 0, 'c4', 1,
                          'A', 'B', 1, 'c4', 1,
                          'A', 'C', 0, 'c4', 1,
                          'A', 'C', 1, 'c4', 1,
                          'A', 'C', 1, 'c4', 1,
                          'B', 'C', 0, 'c4', 1,
                          'B', 'C', 1, 'c4', 1,
                          'B', 'C', 1, 'c4', 1
)
test_btUordereffect<-as.data.frame(test_btUordereffect)



save(test_bt, file = "inst/testdata/test_bt.rda")
save(test_btscores, file = "inst/testdata/test_btscores.rda")
save(test_davidson, file = "inst/testdata/test_davidson.rda")
save(test_davidsonscores, file = "inst/testdata/test_davidsonscores.rda")
save(test_btorder, file = "inst/testdata/test_btorder.rda")
save(test_davidsonorder, file = "inst/testdata/test_davidsonorder.rda")
save(test_btU, file = "inst/testdata/test_btU.rda")
save(test_davidsonU, file = "inst/testdata/test_davidsonU.rda")
save(test_predictors, file = "inst/testdata/test_predictors.rda")
save(test_btUordereffect, file = "inst/testdata/test_btUordereffect.rda")
