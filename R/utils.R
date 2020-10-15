#' Logit function
#' See https://en.wikipedia.org/wiki/Logit
#' @param x p is a probability 0 to 1
#'
#' @return a value between -inf and inf
#' @export
#'
#' @examples
logit<-function(x){
if( any(x < 0 | x > 1) )
  stop('Error! x not between 0 and 1')
 y <- log(x/(1-x))
 return(y)
}

#' Inverse logit function
#' See https://en.wikipedia.org/wiki/Logit
#' @param x is a real -inf to inf
#'
#' @return a value between 0 and 1
#' @export
#'
#' @examples
inv_logit<-function(x){
  y <- exp(x)/(1+exp(x))
  return(y)
}
