#' This is the expansion of the tennis data from  Agresti (2003) p.449
#' This data refers to matches for several women tennis players during 1989 and 1990
#' @name tennis_agresti
#' @docType data
#' @format This is the expansion of the data where each row contains 1 match only
#' * player0: name of player0
#' * player1: name of player1
#' * y: corresponds to the result of the match: 0 if player0 won, 1 if player1 won.
#' * id: is a column to make each row unique in the data. It does not have any particular interpretation
#' @source Agresti, Alan. Categorical data analysis. Vol. 482. John Wiley & Sons, 2003.
#' @keywords data
"tennis_agresti"


#' This is a dataset  with the results matches fromo  the first league of the Brazilian soccer championship from 2017-2019.
#' It was reduced and translatedfrom the adaduque/Brasileirao_Dataset repository
#' @name brasil_soccer_league
#' @docType data
#' @format  Data frame that contains 1140 matches and 9 Columns from the Brazilian soccer championship
#' * Time: time of the day in 24h format
#' * DayWeek: day of the week
#' * Date: date YY-MM-DD
#' * HomeTeam: name of the team playing home
#' * VisitorTeam: name of the team playing visitor
#' * Round: Round number of the championship
#' * Stadium: Name of the stadium where the game was played
#' * ScoreHomeTeam: number of goals for the home team
#' * ScoreVisitorTeam: number of goals for the visitor
#' @source \url{https://github.com/adaoduque/Brasileirao_Dataset}
#' @keywords data
"brasil_soccer_league"


#' Dataset containing an example of the performance of different optimization algorithms against different benchmark functions.
#' This is a reduced version of the dataset presented at the paper: "Statistical Models for the Analysis of Optimization Algorithms with Benchmark Functions.".
#' For details on how the data was collected we refer to the paper.
#' @name optimization_algorithms
#' @docType data
#' @format This is the expansion of the data where each row contains 1 match only
#' * Algorithm: name of algorithm
#' * Benchmark: name of the benchmark problem
#' * TrueRewardDifference: Difference between the minimum function value obtained by the algorithm and the known global minimum
#' * Ndimensions: Number of dimensions of the benchmark problem
#' * MaxFevalPerDimensions: Maximum allowed budget for the algorithm per dimensions of the benchmark problem
#' * simNumber: id of the simulation. Indicates the repeated measures of each algorithm in each benchmark
#' @source Mattos, David Issa, Jan Bosch, and Helena Holmstrom Olsson. Statistical Models for the Analysis of Optimization Algorithms with Benchmark Functions. arXiv preprint arXiv:2010.03783 (2020).
#' @keywords data
"optimization_algorithms"
