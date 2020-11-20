
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bpcs - A package for Bayesian Paired Comparison analysis with Stan <img src="inst/logo/logo.png" align="right" width="120" />

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
sample_n(tennis_agresti,10) %>% 
  knitr::kable()
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

Seles

</td>

<td style="text-align:left;">

Graf

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

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

28

</td>

</tr>

<tr>

<td style="text-align:left;">

Sabatini

</td>

<td style="text-align:left;">

Navratilova

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

35

</td>

</tr>

<tr>

<td style="text-align:left;">

Seles

</td>

<td style="text-align:left;">

Graf

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

4

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

15

</td>

</tr>

<tr>

<td style="text-align:left;">

Seles

</td>

<td style="text-align:left;">

Navratilova

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

12

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

1

</td>

<td style="text-align:right;">

42

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

1

</td>

<td style="text-align:right;">

22

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

Seles

</td>

<td style="text-align:left;">

Sanchez

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

13

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
#> Chain 1: Gradient evaluation took 3e-05 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0.3 seconds.
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
#> Chain 1:  Elapsed Time: 0.096754 seconds (Warm-up)
#> Chain 1:                0.097144 seconds (Sampling)
#> Chain 1:                0.193898 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'bt' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 1.4e-05 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0.14 seconds.
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
#> Chain 2:  Elapsed Time: 0.096757 seconds (Warm-up)
#> Chain 2:                0.103389 seconds (Sampling)
#> Chain 2:                0.200146 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'bt' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 1.7e-05 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0.17 seconds.
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
#> Chain 3:  Elapsed Time: 0.099054 seconds (Warm-up)
#> Chain 3:                0.086801 seconds (Sampling)
#> Chain 3:                0.185855 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'bt' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 9.1e-05 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0.91 seconds.
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
#> Chain 4:  Elapsed Time: 0.09828 seconds (Warm-up)
#> Chain 4:                0.094037 seconds (Sampling)
#> Chain 4:                0.192317 seconds (Total)
#> Chain 4:
```

If `rstan` is available and correctly working this function should
sample the posterior distribution and create a `bpc` object.

To see a summary of the results we can run the summary function. Here we
get three tables:

1- The parameters of the model 2- The probabilities of one player
beating the other (this probability is based on the predictive posterior
distribution) 3- The rank of the player based on their abilities (this
rank is based on the predictive posterior ranks).

``` r
summary(m)
#> Estimated baseline parameters with HPD intervals:
#> 
#> 
#> Parameter               Mean   HPD_lower   HPD_higher    n_eff   Rhat
#> --------------------  ------  ----------  -----------  -------  -----
#> lambda[Seles]           0.51       -2.17         3.29   917.48      1
#> lambda[Graf]            0.94       -1.83         3.54   867.37      1
#> lambda[Sabatini]       -0.34       -3.17         2.23   881.48      1
#> lambda[Navratilova]     0.06       -2.68         2.73   885.46      1
#> lambda[Sanchez]        -1.13       -3.81         1.53   896.53      1
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
#> Graf          Navratilova         0.69
#> Graf          Sabatini            0.76
#> Graf          Sanchez             0.87
#> Graf          Seles               0.59
#> Navratilova   Sabatini            0.59
#> Navratilova   Sanchez             0.74
#> Navratilova   Seles               0.38
#> Sabatini      Sanchez             0.67
#> Sabatini      Seles               0.33
#> Sanchez       Seles               0.18
#> 
#> 
#> Rank of the players' abilities:
#> The rank is based on the posterior rank distribution of the lambda parameter
#> 
#> 
#> Parameter              MedianRank   MeanRank   StdRank
#> --------------------  -----------  ---------  --------
#> lambda[Graf]                    1       1.40      0.62
#> lambda[Seles]                   2       2.08      0.88
#> lambda[Navratilova]             3       2.97      0.88
#> lambda[Sabatini]                4       3.75      0.78
#> lambda[Sanchez]                 5       4.80      0.50
```

# Features of the bpcs package

  - Bayesian computation of different variations of the Bradley-Terry
    (including with home advantage, random effects and the generalized
    model).
  - Bayesian computation of different variations of the Davidson model
    to handle ties in the contest (including with home advantage, random
    effects and the generalized model).
  - Accepts a column with the results of the contest or the scores for
    each player.
  - Customize a normal prior distribution for every parameter.
  - Compute HDP interval for every parameter with the
    `get_hpdi_parameters` function
  - Compute rank of the players with the `get_rank_of_players` function.
  - Compute all the probability combinations for one player beating the
    other with the `get_probabilities` function.
  - Convert aggregated tables of results into long format (one contest
    per row) with the `expand_aggregated_data.`
  - Obtain the posterior distribution for every parameter of the model
    with the `get_sample_posterior` function.
  - Easy predictions using the `predict` function.
  - We do not reinforce any table or plotting library\! Results are
    returned as data frames for easier plotting and creating tables
  - We reinforce the need to manually specify the model to be used.

## Models available

  - Bradley-Terry (`bt`) (Bradley and Terry 1952)
  - Davidson model (`davidson`) for handling ties (Davidson 1970)
  - Bradley-Terry with order effect (`btordereffect`). E.g. for home
    advantage (Davidson and Beaver 1977)
  - Davidson model with order effect (`davidsonordereffect`). E.g. for
    home advantage with ties (Davidson and Beaver 1977)
  - Generalized Bradley-Terry model (`btgeneralized`). When we have
    contestant specific predictors TODO:add ref
  - Generalized Davidson model (`davidsongeneralized`). When we have
    contestant specific predictors and ties TODO:add ref
  - Bradley-Terry model with intercept random effects (`btU`). For
    example to compensate clustering or repeated measures TODO:add ref
  - Davidson model with intercept random effects (`davidsonU`). For
    example to compensate clustering or repeated measures when we have
    ties. TODO:add ref

Note that we currently don’t variations and combinations of these models
(e.g BT with order effect and random effect or generalized BT with order
effect). Contact me if there is a need for one of these models and give
me some examples so we can add to the vignettes\!

## Roadmap

### Goals for bpcs 1.0.0 (before Chirstmas 2020)

  - First official release
  - Working and tested models for `bt`, `btordereffect`,
    `btgeneralized`, `btU`, `davidson`, `davidsonordereffect`,
    `davidsongeneralized`, `davidsonU`
  - Vignettes covering all/most models

### Goals for bpcs 1.1.0 (Before June 2021)

  - Reduce installation time by reducing number of stan models
      - The goal is to have fewer but more general stan models.
      - This will increase the complexity of the stan model but will
        reduce code for the predict, get\_probabilities, and the bpc
        function
  - Add new models for modeling time effects (newer contests have higher
    impact on the ability than older contests)
  - Add model for the Bayesian ELO-type rating system
  - Improve test coverage to 70%

# Vignettes

This package provides a series of small and self contained vignettes
that exemplify the use of each model. In the vignettes, we also provide
examples of code for data transformation, tables and plots.

Below we list all our vignettes with a short description:

  - [Getting
    Started](https://davidissamattos.github.io/bpcs/articles/a_get_started.html):
    This vignette shows a basic example on tennis competition data,
    covering how to run a Bradley-Terry model, MCMC diagnostics,
    posterior predictive values, ranking, predict new matches

  - [Ties and home
    advantage](https://davidissamattos.github.io/bpcs/articles/b_ties_and_home_advantage.html):
    This vignette covers a soccer example from the Brazilian soccer
    league. Here, we first model the results using a Bradley-Terry model
    and the Davidson model to handle ties. Then, we extend both models
    to include for order effects, this allows us to investigate the home
    advantage in and without the presence of ties.

  - [Bradley-Terry with random
    effects](https://davidissamattos.github.io/bpcs/articles/c_bt_random_effects.html):
    This vignette covers the problem of ranking black-box optimization
    algorithms based on benchmarks. Since in benchmarking we often run
    the same optimization algorithm more than once with the same
    benchmark problem, we need to compensate for the repeated measures
    effect. We deal with this utilizing a simple Bradley-Terry model
    with random effects.

\*[Generalized Bradley-Terry model](): This vignette investigate the
Bradley-Terry model when we have players specific characteristics.
(TODO)

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
        list for stan. Don’t forget to add the relevant documentation in
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
        the generic base functions from R, such as `summary`, `print`,
        `predict`
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

There are some dev-functions in inst/devfunctions to help building the
package website and running test coverage (and submitting to codecov).

# Icon credits

  - Boxing gloves image by “surang” from “flaticons.com”
  - Hex Sticker created with the
    [hexSticker](https://github.com/GuangchuangYu/hexSticker) package

# References

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
