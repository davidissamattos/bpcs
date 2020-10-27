#' Logit function
#' @references
#' https://en.wikipedia.org/wiki/Logit
#' @param x p is a probability 0 to 1
#' @return a value between -inf and inf
#' @export
#'
#' @examples
#' logit(0.5)
#' logit(0.2)
logit<-function(x){
if( any(x < 0 | x > 1) )
  stop('Error! x not between 0 and 1')
 y <- log(x/(1-x))
 return(y)
}

#' Inverse logit function
#' @references
#' https://en.wikipedia.org/wiki/Logit
#' @param x is a real -inf to inf
#' @return a value between 0 and 1
#' @export
#'
#' @examples
#' logit(5)
#' logit(-5)
#' logit(0)
inv_logit<-function(x){
  y <- exp(x)/(1+exp(x))
  return(y)
}


### Dev only
code_coverage_with_token<-function(){
  covr::codecov(token = 'e56cbadd-aa85-499a-a6d8-124e4813c031')
}

deploy_pkgdown_site_to_github<-function(){
  code_coverage_with_token()
  rmarkdown::render('README.Rmd',  encoding = 'UTF-8', knit_root_dir = '.')
  pkgdown::build_site(devel = F, preview = F)
  pkgdown::deploy_to_branch()
}
