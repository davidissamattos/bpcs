library(devtools)
compile_and_install<-function(){
  remove.packages('bpc')
  rstantools::rstan_config()
  devtools::document()
  devtools::install(quick = F)
  library(bpc)
}

reload_package<-function(){
  rstantools::rstan_config()
  devtools::document()
  devtools::load_all()
}

test_bpc<-function(){
   m<-bpc(data=citations_agresti,
                player0 = 'journal1',
                player1 = 'journal2',
                player0_score = 'score1',
                player1_score = 'score2',
                model_type='bradleyterry',
                solve_ties='random',
                win_score = 'higher')
}
