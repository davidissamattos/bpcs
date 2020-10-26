
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bpcs - A package for Bayesian Paired Comparison analysis with Stan

<!-- badges: start -->

[![License:
MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://cran.r-project.org/web/licenses/MIT)
[![](https://img.shields.io/github/last-commit/davidissamattos/bpcs.svg)](https://github.com/davidissamattos/bpcs/commits/master)
[![](https://img.shields.io/badge/lifecycle-experimental-blue.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![](https://img.shields.io/github/languages/code-size/davidissamattos/bpcs.svg)](https://github.com/davidissamattos/bpcs)
[![codecov](https://codecov.io/gh/davidissamattos/bpc/branch/master/graph/badge.svg?token=6RTC7768CL)](undefined)

<!-- badges: end -->

The `bpcs` package performs Bayesian estimation of Paired Comparison
models utilizing Stan.

Package documentation and vignette articles can be found at:
<https://davidissamattos.github.io/bpcs/>

## Installation

For the `bpcs` package to work, we rely upon the Stan software and the
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
remotes::install_github('davidissamattos/bpcs')
```

After install we load the package with:

``` r
library(bpcs)
```

## Minimal example

The main function of the package is the `bpc` function. This function
requires a specific type of data frame that contains:

  - Two columns containing the name of the contestants in the paired
    comparison
  - Two columns containing the score of each player OR
  - one column containing the result of the match (0 if player0 won, 1
    if player1 won, -1 if it was a tie)

We will utilize a prepared version of the known dataset available in
(Agresti 2003). The same dataset can also be found in other packages
such as the `BradleyTerry2` (Turner, Firth, and others 2012). The
dataset can be seen below and is available as `data(citations_agresti)`:

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

For the simple Bradley Terry Model we specify the model type as
`'bradleyterry'` . If there are ties in the data we can use a different
model (see vignette: TODO), or we can solve it randomly with the
`'random'` option. Since we provide the scores we need to say who won
`'higher'` if higher score wins or `'lower'` if lower score wins. Here
we hide the MCMC sampler chain messages for simplicity.

``` r
m1<-bpc(data=citations_agresti,
                  player0 = 'journal1',
                  player1 = 'journal2',
                  player0_score = 'score1',
                  player1_score = 'score2',
                  model_type='bradleyterry',
                  solve_ties='random',
                  win_score = 'higher',
        show_chain_messages = F)
```

If `rstan` is available and correctly working this function should
sample the posterior distribution and create a `bpc` object.

To see a summary of the results we can run:

``` r
summary(m1)
#> Estimated parameters:
#>           Parameter       Mean  HPD_lower HPD_higher
#> 1 lambda_Biometrika  0.6137879 -2.1991165  3.3880171
#> 2   lambda_CommStat -1.9684261 -4.8714096  0.9780116
#> 3       lambda_JASA -0.6100828 -3.5704050  2.0365838
#> 4      lambda_JRSSB  1.9884547 -0.9726484  4.9873090
#> 
#> 
#> Probabilities:
#> Warning: The `x` argument of `as_tibble.matrix()` must have unique column names if `.name_repair` is omitted as of tibble 2.0.0.
#> Using compatibility `.name_repair`.
#> This warning is displayed once every 8 hours.
#> Call `lifecycle::last_warnings()` to see where this warning was generated.
#>            i        j       Mean    HPD_lower HPD_Higher
#> 1 Biometrika CommStat 0.84441273 4.631297e-01  0.9997533
#> 2 Biometrika     JASA 0.69670725 2.320458e-01  0.9985325
#> 3 Biometrika    JRSSB 0.29287295 1.364776e-04  0.7884885
#> 4   CommStat     JASA 0.29708510 9.706530e-04  0.7672318
#> 5   CommStat    JRSSB 0.06435339 1.154524e-05  0.2740934
#> 6       JASA    JRSSB 0.14798295 2.300901e-04  0.5562525
```

## Vignettes

This package provides a series of small and self contained vignettes
that exemplify the use of each model. In the vignettes, we also provide
examples of code for data transformation, tables and plots.

Below we list all our vignettes:

  - Getting Started: TODO
  - Handling ties: TODO
  - Bradley-Terry with random effects: TODO

<div id="refs" class="references">

<div id="ref-agresti2003categorical">

Agresti, Alan. 2003. *Categorical Data Analysis*. Vol. 482. John Wiley &
Sons.

</div>

<div id="ref-turner2012bradley">

Turner, Heather, David Firth, and others. 2012. “Bradley-Terry Models in
R: The Bradleyterry2 Package.” *Journal of Statistical Software* 48 (9).

</div>

</div>
