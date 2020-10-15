## code to prepare `citations_agresti` dataset goes here
citations_agresti <- tibble::tribble(~journal1, ~journal2, ~score1, ~score2,
                                     'Biometrika', 'CommStat', 730, 33,
                                     'Biometrika', 'JASA', 498, 320,
                                     'Biometrika', 'JRSSB', 221, 284,
                                     'CommStat', 'JASA',68, 813,
                                     'CommStat', 'JRSSB',17, 276,
                                     'JASA', 'JRSSB', 142, 325
)
usethis::use_data(citations_agresti, overwrite = TRUE)
