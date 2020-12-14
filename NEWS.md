# Roadmap

* TODO: remove dependency from CODA. Currently we have two packages to calculate HDPI. THe goal is to use only the HDInterval package from Kruschke. THis is will also allow to specify the probMass
* TODO: New models being analyzed:
  - Add new models for modeling time effects (newer contests have higher impact on the ability than older contests)
  - Add model for the Bayesian ELO-type rating system
  - Add Glicko and Glicko2 models
  - Add models for cumulative comparisons
  - Add subjective random effects predictors (Bockenholt 2001)
  - Add possibility to add more than one random effects
- TODO: Improve test coverage

# bpcs 1.0.0.900

* removed ties_pred from models that do not have ties
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

