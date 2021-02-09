.onAttach <- function(...) {
  ver <- utils::packageVersion("bpcs")
  mess <-
    paste("This is the version", ver, "of the bpcs package.",
          "\nThe bpcs package requires an installation of cmdstan and an appropriated toolchain.",
          sep = " "
    )


  packageStartupMessage(mess)
  #
  # "\nFor help configuring the toolchain visit:",
  # "\nhttps://mc-stan.org/cmdstanr/articles/cmdstanr.html",
  # "\nTo install cmdstan run: cmdstanr::install_cmdstan()\n",
  # 'cmdstan version: ', cmdstanr::cmdstan_version())
  # cmdstanr::check_cmdstan_toolchain()
}
