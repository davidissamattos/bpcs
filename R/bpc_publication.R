#' Publication-ready table for the parameter estimates
#'
#' @param bpc_object a bpc object
#' @param params a vector with the parameters to be in the table. If NULL them all will be present
#' @param credMass the probability mass for the credible interval
#' @param format A character string. same formats utilized in the knitr::kable function
#' * 'latex': output in latex format
#' * 'simple': appropriated for the console
#' * 'pipe': Pandoc's pipe tables
#' * 'html': for html formats
#' * 'rst'
#' @param digits number of digits in the table
#' @param caption a string containing the caption of the table
#' @param HPDI a boolean if the intervals should be credible (F) or HPD intervals (T)
#' @param n_eff a boolean. Should the number of effective samples be presented (T) or not (F default).
#' @return a formatted table
#' @export
#'
#' @examples
#' \donttest{
#' m<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' t<-get_parameters_table(m)
#' print(t)
#' }
get_parameters_table <-
  function(bpc_object,
           params=NULL,
           credMass = 0.95,
           format = 'latex',
           digits = 3,
           caption = 'Parameters estimates',
           HPDI = T,
           n_eff = F) {
    if (class(bpc_object) != 'bpc')
      stop('Error! The object is not of bpc class')
    t <- get_parameters(bpc_object, credMass=credMass, params=params, HPDI = HPDI,n_eff = n_eff)
    out <-
      knitr::kable(t,
                   format = format,
                   digits = digits,
                   caption = caption,
                   booktabs = T)
    return(out)
  }


#' Publication-ready table for the probabilities
#'
#' @param bpc_object a bpc object
#' @param newdata default to NULL. If used,  it will calculate the probabilities only for the newdata. Otherwise it will calculate for all combinations
#' @param n Number of times to sample from the posterior
#' @param format A character string. same formats utilized in the knitr::kable function
#' * 'latex': output in latex format
#' * 'simple': appropriated for the console
#' * 'pipe': Pandoc's pipe tables
#' * 'html': for html formats
#' * 'rst'
#'  Possible values are latex, html, p, simple (Pandoc's simple tables), and rst.
#' @param digits number of digits in the table
#' @param caption a string containing the caption of the table
#' @param model_type when dealing with some models (such as random effects) one might want to make predictions using the estimated parameters with the random effects but without specifying the specific values of random effects to predict. Therefore one can set a subset of the model to make predictions. For example: a model sampled with bt-U can be used to make predictions of the model bt only.
#' @return a formatted table
#' @export
#'
#' @examples
#' \donttest{
#' m<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' t<-get_probabilities_table(m)
#' print(t)
#' }
get_probabilities_table <-
  function(bpc_object,
           newdata=NULL,
           n=100,
           format = 'latex',
           digits = 3,
           caption = 'Estimated posterior probabilites',
           model_type = NULL) {
    if (class(bpc_object) != 'bpc')
      stop('Error! The object is not of bpc class')
    t <- get_probabilities_df(bpc_object, newdata=newdata, n = n, model_type=model_type)
    out <-
      knitr::kable(t,
                   format = format,
                   digits = digits,
                   caption = caption,
                   booktabs = T)
    return(out)
  }


#' Publication-ready table for the rank table
#'
#' @param bpc_object a bpc object
#' @param format A character string. same formats utilized in the knitr::kable function
#' * 'latex': output in latex format
#' * 'simple': appropriated for the console
#' * 'pipe': Pandoc's pipe tables
#' * 'html': for html formats
#' * 'rst'
#' * 'simple' appropriated for the console
#' @param digits number of digits in the table
#' @param caption a string containing the caption of the table
#' @param n number of times we are sampling the posterior
#' @return a formatted table
#' @export
#'
#' @examples
#' \donttest{
#' m<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' t<-get_rank_of_players_table(m)
#' print(t)
#' }
get_rank_of_players_table <-
  function(bpc_object,
           format = 'latex',
           digits = 3,
           caption = 'Estimated posterior ranks',
           n = 1000) {
    if (class(bpc_object) != 'bpc')
      stop('Error! The object is not of bpc class')
    t <- get_rank_of_players_df(bpc_object , n = n)
    out <-
      knitr::kable(t,
                   format = format,
                   digits = digits,
                   caption = caption,
                   booktabs = T)
    return(out)
  }


#' Return a publication-ready plot for the parameters estimates based on the HPD interval
#' The returned plot is a caterpillar type of plot
#' @param bpc_object a bpc fitted object
#' @param HPDI use HPD (TRUE) or credible intervals (FALSE) for the plots
#' @param params a vector of string for of the parameters to be plotted
#' @param title the title of the plot
#' @param subtitle optional subtitle for the plot
#' @param xaxis title of the x axis
#' @param yaxis title of the y axis
#' @param rotate_x_labels should the labels be shown horizontally (default, FALSE) or vertically (TRUE)
#' @param APA should the graphic be formatted in APA style (default TRUE)
#' @return a ggplot2 caterpillar plot
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' \donttest{
#' m<-bpc(data = tennis_agresti,
#' player0 = 'player0',
#' player1 = 'player1',
#' result_column = 'y',
#' model_type = 'bt',
#' solve_ties = 'none')
#' p<-get_parameters_plot(m)
#' p
#' }
get_parameters_plot <-
  function(bpc_object,
           HPDI = T,
           params = c('lambda'),
           title = 'Parameter estimates',
           subtitle = NULL,
           xaxis = 'Parameter',
           yaxis = 'Value',
           rotate_x_labels = FALSE,
           APA=TRUE) {
    df <- get_parameters(bpc_object,
                         params = params,
                         HPDI = HPDI,
                         n_eff = F,
                         Rhat = F)


    colnames(df) <- c('Parameter', 'Mean', 'Median', 'Lower', 'Higher')
    df <- df %>%
      dplyr::arrange(.data$Mean)

    param_order <- as.array(df$Parameter)

    out <- ggplot2::ggplot(df, ggplot2::aes(x = factor(.data$Parameter, levels = param_order))) + #to order the variables properly we need to convert to factor and use the levels. It is not enough the order of the dataframe
      ggplot2::geom_pointrange(ggplot2::aes(
        ymin = .data$Lower,
        ymax = .data$Higher,
        y = .data$Mean
      )) +
      ggplot2::labs(
        y = yaxis,
        x = xaxis,
        title = title,
        subtitle = subtitle
      )
    if(APA)
      out <- out + jtools::theme_apa()
    if(rotate_x_labels)
      out <- out+ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust=1)) #to rotate we need to adjust the anchor position as well

    return(out)
  }
