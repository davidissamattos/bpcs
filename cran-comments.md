# bpcs 1.0.0.900

* Minor updates to interfaces and bug corrections
* New functions
* Minor improvements

## Test environments

Manual checks:
  - local: x86_64-apple-darwin17.0 (64-bit) R version 4.0.3 (2020-10-10) ---->  OK

Github actions:
  - os: windows-latest, r: 'release' ----> OK
  - os: macOS-latest, r: 'release'   ----> OK
  - os: ubuntu-20.04, r: 'release'   ----> OK
  - os: ubuntu-20.04, r: 'devel'     ----> OK


## R CMD check --as-cran results

There were 0 errors
There were 0 warnings
There was 1 note
  - checking for GNU extensions in Makefiles ... NOTE
  GNU make is a SystemRequirements.
  
## revdep

There are no reverse dependencies

-------------------------------- 

# bpcs 1.0.0

This is the first submission of this package

## Test environments

Manual checks:
  - local: x86_64-apple-darwin17.0 (64-bit) R version 4.0.3 (2020-10-10) ---->  OK
  - win-builder-release ---->  OK
  - win-builder-devel ---->  OK

Github actions:
  - os: windows-latest, r: 'release' ----> OK
  - os: macOS-latest, r: 'release'   ----> OK
  - os: ubuntu-20.04, r: 'release'   ----> OK
  - os: ubuntu-20.04, r: 'devel'     ----> OK


## R CMD check --as-cran results

There were 0 errors
There were 0 warnings
There were 2 notes
  - checking for GNU extensions in Makefiles ... NOTE
  GNU make is a SystemRequirements.
  - checking CRAN incoming feasibility ... NOTE
  New submission
  
## revdep

There are no reverse dependencies
