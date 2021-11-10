# Roadmap

* TODO: New models being analyzed:
  - Add new models for modeling time effects (newer contests have higher impact on the ability than older contests)
  - Add model for the Bayesian ELO-type rating system
  - Add Glicko and Glicko2 models
  - Add models for cumulative comparisons
- TODO: Improve test coverage
* TODO: Get posterior distribution of the parameters without accessing the stanfit object
* TODO: integration with bayesplot to get some of the nice plots that we see there

# bpcs 1.2.2

* fixing problems with `solve_ties` when the ties where provided directly (and not as two separate score [issue #8](https://github.com/davidissamattos/bpcs/issues/8)

# bpcs 1.2.1

* Ability to add credibility mass and choose HDPI or credible intervals in print and in summary
* New function `check_convergence_diagnostics` for HMC diagnostics. This is printed as default in `print` but not in `summary`

# bpcs 1.2.0

* Moving to cmdstanr instead of rstan. 
  - This will allow us to fix some bugs and tweaks that were not optimal.
  - Now we can have faster installations and let cmdstan compile the models.
  - There will be some additional time to compile the models for the first time but that is only the first time we use it
  - We can now remove the errors from ubsan-clang in CRAN which apparently is a lot of trial and error to solve and not supporting tools from CRAN for identifying that
* The interface of the bpcs will remain (practically) the same
* new function to retrieve the posterior distribution of the parameters `get_parameters_posterior`
* alias to retrieve the summary data frame of the parameters `get_parameters_df`
* Removed dependency on coda
* Now we can specify the probability mass in the parameters and in summary
* rstan and shinystan are now optional
* Fix problems with multiple clusters in the posterior predictive function


# bpcs 1.1.0

* Possibility to add up to 3 intercept random effects (hopefully you will never need more than that)
* Model for subject predictors (see example on the paper)
* Make predictions of submodels with the model_type option (see example on the paper)
* Some small bug fixes


# bpcs 1.0.1

* removed ties_pred from models that do not have ties and from the stan models.
* fixed predict for models with ties, so we return a vector y_pred with 0, 1, 2 and not separate as now
* removed posterior distributions from the get_rank_of_players and get_probabilities. Now we have new functions to obtain the data frame or the posterior distributions separately. The posterior is now returned as matrix
* Probabilities table is now optional in the summary function
* New functions to get the probabilities for specific data `get_probabilities_newdata_df` and `get_probabilities_newdata_posterior`
* Publication ready functions for 
  - plots: `get_parameters_plot` function and a thin S3 plot wrapper for the same function. Plots are default to APA.
  - tables: Functions for publication tables: `get_parameter_table`, `get_probabilities_table` and `get_rank_of_players_table`
* `get_hpdi_parameters`  became `get_parameters` and the user specify if credible intervals or hpdi
* Added ties to `expand_aggregated_data`.
* We can get now both credible and HPD intervals in `get_parameters`. n_eff and Rhat are also now possible to add and remove from this df
* Added functions to save and load bpc models

# bpcs 1.0.0

* Package is feature complete and reached version 1.0.0
* Test coverage > 80%
* Bayesian computation of different variations of the Bradley-Terry and the Davidson model to handle ties in the contest (including with home advantage, random effects and the generalized model).
* Input accepts a column with the results of the contest or the scores for each player.
* Customize a normal prior distribution for every parameter.
* Compute HDP interval for every parameter with the `get_hpdi_parameters` function
* Compute rank of the players with the `get_rank_of_players` function.
* Compute all the probability combinations for one player beating the other with the `get_probabilities` function.
* Convert aggregated tables of results into long format (one contest per row) with the `expand_aggregated_data.`
* Obtain the posterior distribution for every parameter of the model with the `get_sample_posterior` function.
* Easy predictions using the `predict` function.
* We do not reinforce any table or plotting library! Results are returned as data frames for easier plotting and creating tables
* We reinforce the need to manually specify the model to be used.
* Full documentation available at the package site
* Dependence on Stan >= 2.20 for faster compilation times
* Removing vignettes from building with the package. Now they are available only in the package website

# bpcs 0.0.0.9000

* Experimental stage
* Basic functionality
* pkgdown site
* starting testing
* add a few Stan models and starting documentation

