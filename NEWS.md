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

