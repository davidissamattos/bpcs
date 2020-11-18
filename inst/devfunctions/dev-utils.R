### Dev only
code_coverage_with_token<-function(){
  covr::codecov(token = 'e56cbadd-aa85-499a-a6d8-124e4813c031')
}

rebuild_documentation<-function(){
  devtools::document()
  devtools::build_readme()
  devtools::build_vignettes()
}

deploy_pkgdown_site_to_github<-function(){
  code_coverage_with_token()
  devtools::install()
  devtools::build_readme()
  devtools::build_vignettes()
  pkgdown::build_site(devel = F, preview = F)
  pkgdown::deploy_to_branch()
}
