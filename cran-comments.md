# bpcs 1.0.0

This is the first submission of this package

## Test environments

Manual checks:
  - local: x86_64-apple-darwin17.0 (64-bit) R version 4.0.3 (2020-10-10) ---->  OK
  - win-builder-release ---->  OK

Github actions:
  - os: windows-latest, r: 'release' ----> OK
  - os: macOS-latest, r: 'release'   ----> OK
  - os: ubuntu-20.04, r: 'release'   ----> OK
  - os: ubuntu-20.04, r: 'devel'     ----> OK


## R CMD check --as-cran results

There were 0 errors
There were 0 warnings
There were 3 notes
  - checking for GNU extensions in Makefiles ... NOTE
  GNU make is a SystemRequirements.
  - checking for GNU extensions in Makefiles ... NOTE
  GNU make is a SystemRequirements.
  - checking CRAN incoming feasibility ... NOTE
  New submission
      
The package makes use of rstan (that also use the Eigen library) and Rcpp that need to be compiled at installation time and requires a large lib folder

One of the internal datasets have names in Portuguese that utilize UTF-8 characters
  
## revdep

There are no reverse dependencies
