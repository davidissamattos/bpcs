## code to prepare `tennis_agresti` dataset goes here
tennis_agresti <- tibble::tribble(~player1, ~player2, ~wins_player1, ~wins_player2,
                                     'Seles', 'Graf', 2, 3,
                                     'Seles', 'Sabatini', 1, 0,
                                     'Seles', 'Navratilova', 3, 3,
                                     'Seles', 'Sanchez', 2, 0,
                                     'Graf', 'Sabatini', 6, 3,
                                     'Graf', 'Navratilova', 3, 0,
                                     'Graf', 'Sanchez', 7, 1,
                                     'Sabatini', 'Navratilova', 1, 2,
                                     'Sabatini', 'Sanchez', 3, 2,
                                     'Navratilova', 'Sanchez',3, 1
)
usethis::use_data(tennis_agresti, overwrite = TRUE)
