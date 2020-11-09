
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bpcs - A package for Bayesian Paired Comparison analysis with Stan

<!-- badges: start -->

[![License:
MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://cran.r-project.org/web/licenses/MIT)
[![](https://img.shields.io/github/last-commit/davidissamattos/bpcs.svg)](https://github.com/davidissamattos/bpcs/commits/master)
[![](https://img.shields.io/badge/lifecycle-experimental-blue.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![](https://img.shields.io/github/languages/code-size/davidissamattos/bpcs.svg)](https://github.com/davidissamattos/bpcs)

[![Codecov test
coverage](https://codecov.io/gh/davidissamattos/bpcs/branch/master/graph/badge.svg)](https://codecov.io/gh/davidissamattos/bpcs?branch=master)
<!-- badges: end -->

The `bpcs` package performs Bayesian estimation of Paired Comparison
models utilizing Stan, such as variations of the Bradley-Terry (Bradley
and Terry 1952) and the Davidson models (Davidson 1970).

Package documentation and vignette articles can be found at:
<https://davidissamattos.github.io/bpcs/>

## Installation

For the `bpcs` package to work, we rely upon the Stan software and the
`rstan` package (Stan Development Team 2020).

  - For general installation of Stan and RStan see:
    <https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started>
  - For macOS:
    <https://github.com/stan-dev/rstan/wiki/Installing-RStan-from-source-on-a-Mac>
  - For Linux:
    <https://github.com/stan-dev/rstan/wiki/Installing-RStan-on-Linux>
  - For Windows:
    <https://github.com/stan-dev/rstan/wiki/Installing-RStan-from-source-on-Windows>

At the moment we are not available in CRAN. To install the bpc package
install directly from our Github repository

``` r
remotes::install_github('davidissamattos/bpcs')
```

After install we load the package with:

``` r
library(bpcs)
```

## Minimal example

The main function of the package is the `bpc` function. For the simple
Bradley-Terry model, this function requires a specific type of data
frame that contains:

  - Two columns containing the name of the contestants in the paired
    comparison
  - Two columns containing the score of each player OR one column
    containing the result of the match (0 if player0 won, 1 if player1
    won, 2 if it was a tie)

We will utilize the tennis dataset available (Agresti 2003). The dataset
can be seen below and is available as `data(tennis_agresti)`:

``` r
knitr::kable(dplyr::sample_n(tennis_agresti,10))
```

<table>

<thead>

<tr>

<th style="text-align:left;">

player0

</th>

<th style="text-align:left;">

player1

</th>

<th style="text-align:right;">

y

</th>

<th style="text-align:right;">

id

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Graf

</td>

<td style="text-align:left;">

Sabatini

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

15

</td>

</tr>

<tr>

<td style="text-align:left;">

Graf

</td>

<td style="text-align:left;">

Sanchez

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

32

</td>

</tr>

<tr>

<td style="text-align:left;">

Seles

</td>

<td style="text-align:left;">

Sanchez

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

14

</td>

</tr>

<tr>

<td style="text-align:left;">

Sabatini

</td>

<td style="text-align:left;">

Sanchez

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

39

</td>

</tr>

<tr>

<td style="text-align:left;">

Graf

</td>

<td style="text-align:left;">

Sabatini

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

19

</td>

</tr>

<tr>

<td style="text-align:left;">

Navratilova

</td>

<td style="text-align:left;">

Sanchez

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

43

</td>

</tr>

<tr>

<td style="text-align:left;">

Graf

</td>

<td style="text-align:left;">

Sabatini

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

16

</td>

</tr>

<tr>

<td style="text-align:left;">

Graf

</td>

<td style="text-align:left;">

Sabatini

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

17

</td>

</tr>

<tr>

<td style="text-align:left;">

Graf

</td>

<td style="text-align:left;">

Sanchez

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

29

</td>

</tr>

<tr>

<td style="text-align:left;">

Navratilova

</td>

<td style="text-align:left;">

Sanchez

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

44

</td>

</tr>

</tbody>

</table>

Based on the scores of each contestant, the `bpc` function computes
automatically who won the contest. Alternatively, you can provide a
vector of who won if that is already available (for more information see
`?bpc`.

For the simple Bradley Terry Model we specify the model type as `'bt'`.
Here we hide the MCMC sampler chain messages for simplicity in the
output.

``` r
m<-bpc(data = tennis_agresti, #datafrane
       player0 = 'player0', #name of the column for player 0
       player1 = 'player1', #name of the column for player 1
       result_column = 'y', #name of the column for the result of the match
       model_type = 'bt', #bt = Simple Bradley Terry model
       solve_ties = 'none' #there are no ties in the dataset so we can choose none here
       )
#> 
#> SAMPLING FOR MODEL 'bt' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 3.7e-05 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0.37 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: Iteration:    1 / 2000 [  0%]  (Warmup)
#> Chain 1: Iteration:  200 / 2000 [ 10%]  (Warmup)
#> Chain 1: Iteration:  400 / 2000 [ 20%]  (Warmup)
#> Chain 1: Iteration:  600 / 2000 [ 30%]  (Warmup)
#> Chain 1: Iteration:  800 / 2000 [ 40%]  (Warmup)
#> Chain 1: Iteration: 1000 / 2000 [ 50%]  (Warmup)
#> Chain 1: Iteration: 1001 / 2000 [ 50%]  (Sampling)
#> Chain 1: Iteration: 1200 / 2000 [ 60%]  (Sampling)
#> Chain 1: Iteration: 1400 / 2000 [ 70%]  (Sampling)
#> Chain 1: Iteration: 1600 / 2000 [ 80%]  (Sampling)
#> Chain 1: Iteration: 1800 / 2000 [ 90%]  (Sampling)
#> Chain 1: Iteration: 2000 / 2000 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.098469 seconds (Warm-up)
#> Chain 1:                0.090781 seconds (Sampling)
#> Chain 1:                0.18925 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'bt' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 1.6e-05 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0.16 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: Iteration:    1 / 2000 [  0%]  (Warmup)
#> Chain 2: Iteration:  200 / 2000 [ 10%]  (Warmup)
#> Chain 2: Iteration:  400 / 2000 [ 20%]  (Warmup)
#> Chain 2: Iteration:  600 / 2000 [ 30%]  (Warmup)
#> Chain 2: Iteration:  800 / 2000 [ 40%]  (Warmup)
#> Chain 2: Iteration: 1000 / 2000 [ 50%]  (Warmup)
#> Chain 2: Iteration: 1001 / 2000 [ 50%]  (Sampling)
#> Chain 2: Iteration: 1200 / 2000 [ 60%]  (Sampling)
#> Chain 2: Iteration: 1400 / 2000 [ 70%]  (Sampling)
#> Chain 2: Iteration: 1600 / 2000 [ 80%]  (Sampling)
#> Chain 2: Iteration: 1800 / 2000 [ 90%]  (Sampling)
#> Chain 2: Iteration: 2000 / 2000 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.097283 seconds (Warm-up)
#> Chain 2:                0.108081 seconds (Sampling)
#> Chain 2:                0.205364 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'bt' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 1.5e-05 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0.15 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: Iteration:    1 / 2000 [  0%]  (Warmup)
#> Chain 3: Iteration:  200 / 2000 [ 10%]  (Warmup)
#> Chain 3: Iteration:  400 / 2000 [ 20%]  (Warmup)
#> Chain 3: Iteration:  600 / 2000 [ 30%]  (Warmup)
#> Chain 3: Iteration:  800 / 2000 [ 40%]  (Warmup)
#> Chain 3: Iteration: 1000 / 2000 [ 50%]  (Warmup)
#> Chain 3: Iteration: 1001 / 2000 [ 50%]  (Sampling)
#> Chain 3: Iteration: 1200 / 2000 [ 60%]  (Sampling)
#> Chain 3: Iteration: 1400 / 2000 [ 70%]  (Sampling)
#> Chain 3: Iteration: 1600 / 2000 [ 80%]  (Sampling)
#> Chain 3: Iteration: 1800 / 2000 [ 90%]  (Sampling)
#> Chain 3: Iteration: 2000 / 2000 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.094476 seconds (Warm-up)
#> Chain 3:                0.110252 seconds (Sampling)
#> Chain 3:                0.204728 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'bt' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 1.5e-05 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0.15 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: Iteration:    1 / 2000 [  0%]  (Warmup)
#> Chain 4: Iteration:  200 / 2000 [ 10%]  (Warmup)
#> Chain 4: Iteration:  400 / 2000 [ 20%]  (Warmup)
#> Chain 4: Iteration:  600 / 2000 [ 30%]  (Warmup)
#> Chain 4: Iteration:  800 / 2000 [ 40%]  (Warmup)
#> Chain 4: Iteration: 1000 / 2000 [ 50%]  (Warmup)
#> Chain 4: Iteration: 1001 / 2000 [ 50%]  (Sampling)
#> Chain 4: Iteration: 1200 / 2000 [ 60%]  (Sampling)
#> Chain 4: Iteration: 1400 / 2000 [ 70%]  (Sampling)
#> Chain 4: Iteration: 1600 / 2000 [ 80%]  (Sampling)
#> Chain 4: Iteration: 1800 / 2000 [ 90%]  (Sampling)
#> Chain 4: Iteration: 2000 / 2000 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.095463 seconds (Warm-up)
#> Chain 4:                0.106626 seconds (Sampling)
#> Chain 4:                0.202089 seconds (Total)
#> Chain 4:
```

If `rstan` is available and correctly working this function should
sample the posterior distribution and create a `bpc` object.

To see a summary of the results we can run:

``` r
summary(m)
#> Estimated baseline parameters with HPD intervals:
#> 
#> 
#> Parameter                    Mean   HPD_lower   HPD_higher
#> --------------------  -----------  ----------  -----------
#> lambda[Seles]           0.5683669   -2.277996     3.234834
#> lambda[Graf]            1.0029280   -1.674701     3.756607
#> lambda[Sabatini]       -0.2717468   -3.118871     2.441182
#> lambda[Navratilova]     0.1081579   -2.594889     2.843757
#> lambda[Sanchez]        -1.0404282   -3.760021     1.801204
#> NOTES:
#> * A higher lambda indicates a higher team ability
#> 
#> 
#> Posterior probabilities:
#> These probabilities are calculated from the predictive posterior distribution
#> for all player combinations
#> 
#> 
#> i             j              i_beats_j
#> ------------  ------------  ----------
#> Graf          Navratilova         0.70
#> Graf          Sabatini            0.77
#> Graf          Sanchez             0.86
#> Graf          Seles               0.58
#> Navratilova   Sabatini            0.59
#> Navratilova   Sanchez             0.75
#> Navratilova   Seles               0.41
#> Sabatini      Sanchez             0.66
#> Sabatini      Seles               0.32
#> Sanchez       Seles               0.19
#> 
#> 
#> Rank of the players' abilities:
#> The rank is based on the posterior rank distribution of the lambda parameter
#> 
#> 
#> Parameter              MedianRank   MeanRank   StdRank
#> --------------------  -----------  ---------  --------
#> lambda[Graf]                    1       1.37      0.61
#> lambda[Seles]                   2       2.15      0.91
#> lambda[Navratilova]             3       3.00      0.88
#> lambda[Sabatini]                4       3.73      0.84
#> lambda[Sanchez]                 5       4.76      0.54
```

# Features of the bpcs package

  - Bayesian computation of different variations of the Bradley-Terry
    and the Davidson model (see types of model next) including with home
    advantage, ties, random effects and generalized

  - Accepts a column with the results of the contest or the scores for
    each player

  - Custom Normal priors for every parameter

  - 
## Models available

  - Bradley-Terry (Bradley and Terry 1952)
  - Davidson model for handling ties (Davidson 1970)
  - Bradley-Terry with order effect. E.g. for home advantage (Davidson
    and Beaver 1977)
  - Davidson model with order effect. E.g. for home advantage with ties
    (Davidson and Beaver 1977)
  - Generalized Bradley-Terry model. When we have subject specific
    predictors (same for all contestants) TODO:add ref
  - Generalized Davidson model. When we have subject specific predictors
    (same for all contestants) and ties TODO:add ref
  - Bradley-Terry model with intercept random effects. For example to
    compensate clustering or repeated measures TODO:add ref
  - Davidson model with intercept random effects. For example to
    compensate clustering or repeated measures when we have ties.
    TODO:add ref

Note that we currently don’t variations and combinations of these models
(e.g BT with order effect and random effect or generalized BT with order
effect). Contact me if there is a need for one of these models and give
me some examples so we can add to the vignettes\!

## Roadmap

### Goals for bpcs 1.0.0 (before Chirstmas 2020)

  - First official release
  - Working and tested models for bt, btordereffect, btgeneralized, btU,
    davidson, davidsonordereffect, davidsongeneralized, davidsonU
  - Minimum coverage of 60%
  - Vignettes covering all models

### Goals for bpcs 1.1.0 (Before June 2021)

  - Reduce installation time by reducing number of stan models
      - The goal is to have 2-4 stan models only
      - This will also greatly reduce code for predict, and the bpc
        function
  - Add new models for modeling time effects
  - 70% coverage

# Vignettes

This package provides a series of small and self contained vignettes
that exemplify the use of each model. In the vignettes, we also provide
examples of code for data transformation, tables and plots.

Below we list all our vignettes with a short description:

  - [Getting
    Started](https://davidissamattos.github.io/bpcs/articles/get_started.html):
    This vignette shows a basic example on tennis competition data,
    covering how to run a Bradley-Terry model, MCMC diagnostics,
    posterior predictive values, ranking, predict new matches
  - [Handling ties](): This vignette covers a soccer example from the
    Brazilian soccer league. Here, we use the Davidson extension of the
    Bradley-Terry model to handle ties. (TODO)
  - [Home advantage](): This vignette covers a soccer example from the
    Brazilian soccer league. Here, we both the extension of the
    Bradley-Terry model for order effects to investigate the home
    advantage and the Davidson extension to include order effects to
    investigate home advantage in the presence of ties. (TODO)
  - [Bradley-Terry with random effects](): This vignette covers the
    problem of ranking black-box optimization algorithms based on
    benchmarks. Since in benchmarking we often run the same optimization
    algorithm more than once with the same benchmark problem, we need to
    compensate for the repeated measures effect. We deal with this
    utilizing a simple Bradley-Terry model with random effects. In the
    presence of this, we also have a variation of the Davidson model to
    include random effects. (TODO) \*[Generalized Bradley-Terry
    model](): This vignette investigate the Bradley-Terry model when we
    have players specific characteristics. (TODO)

# Contributing

If you are interested you are welcome to contribute to the repository
through pull requests.

If you have a strong need for a model that is not covered in this
package (and do not want to code it yourself) send me an email or a
suggestion in Github

## Short guide/suggestions

The points below are mostly reminders for me but hopefully it can help
others

  - Use the `devtools` package to create R files, test files, vignettes
    etc
  - In the R folder:
      - `bpc.R`: this contains a single function (rather large) that is
        the main function call of the package. Each new model should be
        added here in the if else section with the appropriated data
        list for stan. Dont forget to add the relevant documentation in
        roxygen2
      - `bpc_exports.R`: these are helper functions to handle the `bpc`
        object and are exposed to the user. Only add here functions that
        receive a bpc object and that the users will have an interest.
      - `bpc_get_probabilities.R` Since this is a big export function we
        have moved it to its own file
      - `bpc_helpers_X.R` additional functions to facilitate and support
        either the bpc function or the exports functions. None of these
        functions should be exported, although all of them should be
        documented. We divided these helpers in several files. the
        indexes are related to creating and checking names and indexes
        in lookup tables, the hpd to HPDI related functions, the checks
        to check correct specification of the data frame columns
      - `bpc_s3.R` all functions here are the custom implementation of
        the generic base functions from R, such as summary, print,
        predict
      - `utils.R` dev functions to only. Not to be exported or used by
        the end user
      - `data-docs.R` documentation for the data.
      - `bpc_object.R` declaration and creation of the bpc class.
  - To add new models:
    1.  Add the stan file with the model in inst/stan.
    <!-- end list -->
      - Note that we add two stan files for each model, one that will
        estimate the parameters and one that will make predictions
    <!-- end list -->
    3.  add the appropriated hooks in the `bpc` function in `bpc.R` so
        we can call the model
    4.  add the appropriated hooks in the `predict` function in
        `bpc_s3.R`.
    5.  add the appropriated hooks for the `get_probabilities` function
        in `bpc_get_probabilities.R` to generate the appropriated
        probability table that is called in the `summary` function.
    6.  add the relevant tests to each of the modifications (to be
        improved with time, since we have very few tests now)
  - Problems with `rstantools` and compiling the models. For me at
    least, the combination of `RStudio`+ `rstantools` + `roxygen2` +
    `devtools` + `Rcpp`+ `devtools` gives an assorted amount of
    stochastic errors can usually be solved with a combination of the
    actions below. For me it is still trial and error to fix the error
    but it usually works with these actions:
      - Restart the r session and try `devtools::load_all()` again
      - After adding a model try `devtools::document()`
      - If deleting a model file delete the appropriated line in
        stanmodels.R and do document again
      - If the model is not recompiling or updating do
        `pkgbuild::clean_dll()` then `devtools::document()` and possibly
        `devtools::load_all()` or `devtools::install()`

<div id="refs" class="references">

<div id="ref-agresti2003categorical">

Agresti, Alan. 2003. *Categorical Data Analysis*. Vol. 482. John Wiley &
Sons.

</div>

<div id="ref-bradley1952rank">

Bradley, Ralph Allan, and Milton E Terry. 1952. “Rank Analysis of
Incomplete Block Designs: I. The Method of Paired Comparisons.”
*Biometrika* 39 (3/4): 324–45.

</div>

<div id="ref-davidson1970extending">

Davidson, Roger R. 1970. “On Extending the Bradley-Terry Model to
Accommodate Ties in Paired Comparison Experiments.” *Journal of the
American Statistical Association* 65 (329): 317–28.

</div>

<div id="ref-davidson1977extending">

Davidson, Roger R, and Robert J Beaver. 1977. “On Extending the
Bradley-Terry Model to Incorporate Within-Pair Order Effects.”
*Biometrics*, 693–702.

</div>

<div id="ref-rstan">

Stan Development Team. 2020. “RStan: The R Interface to Stan.”
<http://mc-stan.org/>.

</div>

</div>
