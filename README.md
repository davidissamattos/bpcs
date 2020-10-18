
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bpc - A package for Bayesian Paired Comparison analysis

<!-- badges: start -->

<!-- badges: end -->

The `bpc` package performs Bayesian estimation of Paired Comparison
models utilizing Stan.

## Installation

For the `bpc` package to work, we rely upon the Stan software and the
`rstan` package.

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
remotes::install_github('https://github.com/davidissamattos/bpc')
```

After install we load the package with:

``` r
library(bpc)
```

## Example

The main function of the package is the `bpc` function. This function
requires a specific type of data frame that contains:

  - Two columns containing the name of the contestants in the paired
    comparison
  - Two columns containing the score of each player OR
  - one column containing the result of the match (0 if player0 won, 1
    if player1 won, -1 if it was a tie)

We will utilize a prepared version of the known dataset available in
Agresti 2002. The same dataset can also be found in other packages such
as the `BradleyTerry2`. The dataset can be seen below and is available
as `data(citations_agresti)`:

``` r
knitr::kable(citations_agresti)
```

<table>

<thead>

<tr>

<th style="text-align:left;">

journal1

</th>

<th style="text-align:left;">

journal2

</th>

<th style="text-align:right;">

score1

</th>

<th style="text-align:right;">

score2

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Biometrika

</td>

<td style="text-align:left;">

CommStat

</td>

<td style="text-align:right;">

730

</td>

<td style="text-align:right;">

33

</td>

</tr>

<tr>

<td style="text-align:left;">

Biometrika

</td>

<td style="text-align:left;">

JASA

</td>

<td style="text-align:right;">

498

</td>

<td style="text-align:right;">

320

</td>

</tr>

<tr>

<td style="text-align:left;">

Biometrika

</td>

<td style="text-align:left;">

JRSSB

</td>

<td style="text-align:right;">

221

</td>

<td style="text-align:right;">

284

</td>

</tr>

<tr>

<td style="text-align:left;">

CommStat

</td>

<td style="text-align:left;">

JASA

</td>

<td style="text-align:right;">

68

</td>

<td style="text-align:right;">

813

</td>

</tr>

<tr>

<td style="text-align:left;">

CommStat

</td>

<td style="text-align:left;">

JRSSB

</td>

<td style="text-align:right;">

17

</td>

<td style="text-align:right;">

276

</td>

</tr>

<tr>

<td style="text-align:left;">

JASA

</td>

<td style="text-align:left;">

JRSSB

</td>

<td style="text-align:right;">

142

</td>

<td style="text-align:right;">

325

</td>

</tr>

</tbody>

</table>

Based on the scores of each contestant, the `bpc` function computes
automatically who won the contest. Alternatively, you can provide a
vector of who won if that is already available (for more information see
`?bpc`.

For the simple Bradley Terry Model we specify `bradleyterry` as the
model\_type. If there are ties in the data we can use a different model
(see vignette: X), or we can solve it randomly with the `random` option.
Since we provide the scores we need to say who won `higher` if higher
score wins or `lower` if lower score wins.

``` r
  m1<-bpc(data=citations_agresti,
                  player0 = 'journal1',
                  player1 = 'journal2',
                  player0_score = 'score1',
                  player1_score = 'score2',
                  model_type='bradleyterry',
                  solve_ties='random',
                  win_score = 'higher')
#> 
#> SAMPLING FOR MODEL 'bt' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 2.2e-05 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0.22 seconds.
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
#> Chain 1:  Elapsed Time: 0.022735 seconds (Warm-up)
#> Chain 1:                0.026234 seconds (Sampling)
#> Chain 1:                0.048969 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'bt' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 9e-06 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0.09 seconds.
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
#> Chain 2:  Elapsed Time: 0.023715 seconds (Warm-up)
#> Chain 2:                0.026985 seconds (Sampling)
#> Chain 2:                0.0507 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'bt' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 9e-06 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0.09 seconds.
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
#> Chain 3:  Elapsed Time: 0.025489 seconds (Warm-up)
#> Chain 3:                0.025532 seconds (Sampling)
#> Chain 3:                0.051021 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'bt' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 9e-06 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0.09 seconds.
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
#> Chain 4:  Elapsed Time: 0.025794 seconds (Warm-up)
#> Chain 4:                0.021178 seconds (Sampling)
#> Chain 4:                0.046972 seconds (Total)
#> Chain 4:
```

If rstan is available and correctly working this function should sample
the posterior distribution and create a `bpc` object.

To see a summary of the results we can run:

``` r
summary(m1)
#>              Length Class      Mode     
#> Nplayers      1     -none-     numeric  
#> stanfit       1     stanfit    S4       
#> hpdi          4     data.frame list     
#> lookup_table  2     data.frame list     
#> model_type    1     -none-     character
#> standata      6     -none-     list     
#> call_arg     13     -none-     list
```

## Documentation

## Vignettes

This package provides a series of small and self contained vignettes
that exemplify the use of each model. In the vignettes, we also provide
examples of code for data transformation, tables and plots.

Below we list all our vignettes:

  - Getting Started:
  - Handling ties:
  - Bradley-Terry with random effects
