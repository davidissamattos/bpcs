
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bpcs - A package for Bayesian Paired Comparison analysis with Stan <img src='man/figures/logo.png' align="right" width="120" />

<!-- badges: start -->

[![License:
MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://cran.r-project.org/web/licenses/MIT)
[![](https://img.shields.io/github/last-commit/davidissamattos/bpcs.svg)](https://github.com/davidissamattos/bpcs/commits/master)
[![](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://www.tidyverse.org/lifecycle/#stable)
[![](https://img.shields.io/github/languages/code-size/davidissamattos/bpcs.svg)](https://github.com/davidissamattos/bpcs)
[![](https://img.shields.io/badge/devel%20version-1.0.0.900-blue.svg)](https://github.com/davidissamattos/bpcs)
[![](https://www.r-pkg.org/badges/version/bpcs?color=blue)](https://cran.r-project.org/package=bpcs)
[![](https://codecov.io/gh/davidissamattos/bpcs/branch/master/graph/badge.svg)](https://codecov.io/gh/davidissamattos/bpcs)
[![R build
status](https://github.com/davidissamattos/bpcs/workflows/R-CMD-check/badge.svg)](https://github.com/davidissamattos/bpcs/actions)
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
    <https://github.com/stan-dev/rstan>

To install the latest stable version from CRAN

``` r
install.packages('bpcs')
```

To install the development version of the bpcs package, install directly
from the Github repository.

``` r
remotes::install_github('davidissamattos/bpcs')
```

After installing, we load the package with:

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
dplyr::sample_n(tennis_agresti,10) %>% 
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

Navratilova

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

8

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

40

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

1

</td>

<td style="text-align:right;">

46

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

27

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

Navratilova

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

10

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
#> Chain 1: Gradient evaluation took 0.000111 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 1.11 seconds.
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
#> Chain 1:  Elapsed Time: 0.308794 seconds (Warm-up)
#> Chain 1:                0.331351 seconds (Sampling)
#> Chain 1:                0.640145 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'bt' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 4e-05 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0.4 seconds.
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
#> Chain 2:  Elapsed Time: 0.303815 seconds (Warm-up)
#> Chain 2:                0.34211 seconds (Sampling)
#> Chain 2:                0.645925 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'bt' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 3.8e-05 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0.38 seconds.
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
#> Chain 3:  Elapsed Time: 0.293928 seconds (Warm-up)
#> Chain 3:                0.334411 seconds (Sampling)
#> Chain 3:                0.628339 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'bt' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 3.5e-05 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0.35 seconds.
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
#> Chain 4:  Elapsed Time: 0.307246 seconds (Warm-up)
#> Chain 4:                0.284794 seconds (Sampling)
#> Chain 4:                0.59204 seconds (Total)
#> Chain 4:
```

If `rstan` is available and correctly working this function should
sample the posterior distribution and create a `bpc` object.

To see a summary of the results we can run the summary function. Here we
get three tables:

1.  The parameters of the model
2.  The probabilities of one player beating the other (this probability
    is based on the predictive posterior distribution)
3.  The rank of the player based on their abilities (this rank is based
    on the predictive posterior ranks).

<!-- end list -->

``` r
summary(m)
#> Estimated baseline parameters with HPD intervals:
#> 
#> 
#> Table: Parameters estimates
#> 
#> Parameter               Mean   HPD_lower   HPD_higher    n_eff
#> --------------------  ------  ----------  -----------  -------
#> lambda[Seles]           0.59       -1.99         3.35   671.03
#> lambda[Graf]            1.02       -1.54         3.64   613.82
#> lambda[Sabatini]       -0.26       -2.86         2.41   643.46
#> lambda[Navratilova]     0.12       -2.47         2.83   673.31
#> lambda[Sanchez]        -1.04       -3.88         1.52   657.55
#> NOTES:
#> * A higher lambda indicates a higher team ability
#> 
#> 
#> Posterior probabilities:
#> These probabilities are calculated from the predictive posterior distribution
#> for all player combinations
#> 
#> 
#> Table: Estimated posterior probabilites
#> 
#> i             j              i_beats_j   j_beats_i
#> ------------  ------------  ----------  ----------
#> Graf          Navratilova         0.30        0.70
#> Graf          Sabatini            0.24        0.76
#> Graf          Sanchez             0.13        0.87
#> Graf          Seles               0.41        0.59
#> Navratilova   Sabatini            0.43        0.57
#> Navratilova   Sanchez             0.27        0.73
#> Navratilova   Seles               0.59        0.41
#> Sabatini      Sanchez             0.32        0.68
#> Sabatini      Seles               0.67        0.33
#> Sanchez       Seles               0.81        0.19
#> 
#> 
#> Rank of the players' abilities:
#> The rank is based on the posterior rank distribution of the lambda parameter
#> 
#> 
#> Table: Estimated posterior ranks
#> 
#> Parameter              MedianRank   MeanRank   StdRank
#> --------------------  -----------  ---------  --------
#> lambda[Graf]                    1       1.38      0.62
#> lambda[Seles]                   2       2.12      0.88
#> lambda[Navratilova]             3       3.03      0.91
#> lambda[Sabatini]                4       3.69      0.83
#> lambda[Sanchez]                 5       4.78      0.52
```

``` r
plot(m, rotate_x_labels = T)
```

<img src="man/figures/README-unnamed-chunk-8-1.png" width="100%" />

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
  - Compute HDP interval for every parameter with the `get_parameters`
    function
  - Compute rank of the players with the `get_rank_of_players_df`
    function.
  - Compute all the probability combinations for one player beating the
    other with the `get_probabilities_df` function.
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

Options to add to the models:

  - Order effect (`-ordereffect`). E.g. for home advantage (Davidson and
    Beaver 1977)
  - Generalized models (`-generalized`). When we have contestant
    specific predictors (Springall 1973)
  - Intercept random effects (`-U`). For example, to compensate
    clustering or repeated measures (Böckenholt 2001)

E.g.:

  - Simple BT model: `bt`
  - Davidson model with random effects: `davidson-U`
  - Generalized BT model with order effect: `bt-generalized-ordereffect`

Notes:

  - The model type should be first
  - The order of the options do not matter: `bt-U-ordereffect` is
    equivalent to `bt-ordereffect-U`
  - The `-` is mandatory

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

<!-- * [Generalized Bradley-Terry model](): This vignette investigate the Bradley-Terry model when we have players specific characteristics. (TODO) -->

<!-- * [Paper](): This paper/vignette describes the theory and related work behind the presented models. TODO -->

# Contributing and bugs

If you are interested you are welcome to contribute to the repository
through pull requests.

We have a short [contributing guide
vignette](https://davidissamattos.github.io/bpcs/articles/e_contributing.html).

If you find bugs, please report it in
<https://github.com/davidissamattos/bpcs/issues>

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

<div id="ref-bockenholt2001hierarchical">

Böckenholt, Ulf. 2001. “Hierarchical Modeling of Paired Comparison
Data.” *Psychological Methods* 6 (1): 49.

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

<div id="ref-springall1973response">

Springall, A. 1973. “Response Surface Fitting Using a Generalization of
the Bradley-Terry Paired Comparison Model.” *Journal of the Royal
Statistical Society: Series C (Applied Statistics)* 22 (1): 59–68.

</div>

<div id="ref-rstan">

Stan Development Team. 2020. “RStan: The R Interface to Stan.”
<https://mc-stan.org/>.

</div>

</div>
