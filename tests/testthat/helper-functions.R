load_testdata<-function(dataset){
  dataset<-paste(dataset,".rda",sep = "")
  f<-system.file("testdata",dataset, package = "bpcs",mustWork = TRUE)
  out<-get(load(file=f))
  return(out)
}


#save and restore previous seed locally

get_rand_state <- function() {
  # Using `get0()` here to have `NULL` output in case object doesn't exist.
  # Also using `inherits = FALSE` to get value exactly from global environment
  # and not from one of its parent.
  get0(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
}
set_rand_state <- function(state) {
  # Assigning `NULL` state might lead to unwanted consequences
  if (!is.null(state)) {
    assign(".Random.seed", state, envir = .GlobalEnv, inherits = FALSE)
  }
}
