##########################################################################################
#
##########################################################################################
#' The application server-side logic
#'
#' Wires up the module of each tab. Each tab has its own server picker, and
#' downloads its own data.
#'
#' @param input,output,session Internal parameters for `{shiny}`.
#'   DO NOT REMOVE.
#'
#' @import shiny
#' @noRd
#'
#' @examples
#' \dontrun{
#' shiny::shinyApp(ui = app_ui, server = app_server)
#' }
app_server <- function(input, output, session) {
  # sent by dark_mode.js: the colors of the heatmap are drawn here, out of reach of dark_mode.css
  dark_mode <- reactive(if (isTRUE(input$dark_mode)) "dark" else "light")
  mod_current_server("current")
  mod_timeseries_server("timeseries")
  mod_daily_pattern_server("daily_pattern", dark_mode)
  mod_air_quality_server("air_quality", dark_mode)
}
