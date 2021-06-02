#' Return a plot for the parameters estimates based on the HPD interval
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
#' @param keep_par_name keep the parameter name e.g. lambda Graff instead of Graff. Default to T. Only valid for lambda, so we can have better ranks
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
           APA=TRUE,
           keep_par_name = TRUE) {
    df <- get_parameters(bpc_object,
                         params = params,
                         HPDI = HPDI,
                         n_eff = F,
                         Rhat = F,
                         keep_par_name = keep_par_name)

    if(params==c('lambda') & keep_par_name == FALSE){
      df$Parameter<-stringr::str_remove(df$Parameter,stringr::fixed("lambda["))
      df$Parameter<-stringr::str_remove(df$Parameter,stringr::fixed("]"))
    }


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
