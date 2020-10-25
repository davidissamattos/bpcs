## code to prepare `test_ties` dataset goes here
test_ties<-tibble::tribble(~player0, ~player1, ~y,
           1, 2, 0,
           1, 2, 0,
           1, 2, 2,
           1, 3, 0,
           1, 3, 0,
           1, 3, 0,
           2, 3, 0,
           2, 3, 0,
           2, 3, 2)

usethis::use_data(test_ties, overwrite = TRUE)
