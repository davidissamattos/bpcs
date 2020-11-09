## code to prepare `optimization_algorithms` dataset goes here
optimization_algorithms<-readr::read_csv('data-raw/statscomp.csv') %>%
  dplyr::select(Algorithm, Benchmark=CostFunction, TrueRewardDifference, Ndimensions, OptimizationSuccessful, MaxFevalPerDimensions, simNumber,SD) %>%
  dplyr::filter(MaxFevalPerDimensions==100000) %>%
  dplyr::filter(OptimizationSuccessful==TRUE) %>%
  dplyr::filter(SD==0) %>%
  dplyr::filter(Algorithm!="RandomSearch2" & Algorithm!="CuckooSearch") %>%
  dplyr::select(-OptimizationSuccessful, -SD)

usethis::use_data(optimization_algorithms, overwrite = TRUE)
