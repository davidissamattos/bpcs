# bpcs 1.0.0

This is the first submission of this package

## Test environments

* local: x86_64-apple-darwin17.0 (64-bit) R version 4.0.2 (2020-06-22) - OK
* win-builder-release - OK

## R CMD check results

There were 0 errors
There were 0 warnings
There were 3 notes
  * checking for GNU extensions in Makefiles ... NOTE
  GNU make is a SystemRequirements.
  * checking for GNU extensions in Makefiles ... NOTE
  GNU make is a SystemRequirements.
  * checking data for non-ASCII characters ... NOTE
  Note: found 1448 marked UTF-8 strings
      
The package makes use of rstan and Rcpp that need to be compiled and requires a large lib folder

One of the internal datasets have names in Portuguese that utilize UTF-8 characters
  
## revdep

There are no reverse dependencies
