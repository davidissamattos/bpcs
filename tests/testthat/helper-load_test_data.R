load_testdata<-function(dataset){
  dataset<-paste(dataset,".rda",sep = "")
  f<-system.file("testdata",dataset, package = "bpcs",mustWork = TRUE)
  out<-get(load(file=f))
  return(out)
}
