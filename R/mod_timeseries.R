##########################################################################################
#
##########################################################################################
#' @title Time Series module - UI
#' @description A server, a sensor and a period to pick (6 hours to 1 year), in
#' the order of the Daily Pattern tab, and a chart of that sensor, with a full
#' screen button (see `inst/app/www/plot_zoom.js`).
#' @param id Character. Module namespace id.
#' @param prometheus_url Character vector of Prometheus urls to choose from.
#' @return A `tagList` of Shiny UI elements.
#' @keywords internal
#' @examples
#' \dontrun{
#' shiny::fluidPage(
#'   golemenviro:::mod_timeseries_ui("timeseries", "http://pip1.crabdance.com:1507/api/v1/query_range")
#' )
#' }
mod_timeseries_ui <- function(id, prometheus_url) {
  ns <- NS(id)
  # the periods to choose from, in days
  periods <- c(
    "6 hours" = 0.25, "12 hours" = 0.5, "24 hours" = 1, "3 days" = 3, "1 week" = 7, "2 weeks" = 14,
    "1 month" = 30, "3 months" = 90, "6 months" = 180, "9 months" = 270, "1 year" = 365
  )
  tagList(
    fluidRow(
      column(width = 4, selectInput(ns("server_timeseries"), label = "Server", choices = c(prometheus_url), selected = prometheus_url[1], width = "600px")),
      column(width = 4, selectInput(ns("sensor"), label = "Sensor", choices = stats::setNames(metrics, sensor_label(metrics)), selected = "temperature")),
      column(width = 4, selectInput(ns("days"), label = "Period", choices = periods, selected = 7))
    ),
    fluidRow(div(
      class = "plotly-full-screen",
      column(width = 12, class = "sensor-box", plotly::plotlyOutput(ns("plot"), height = "600px"))
    ))
  )
}
##########################################################################################
#
##########################################################################################
#' @title Time Series module - server
#' @description Downloads the readings of all the sensors for the chosen number
#' of days when the server or the number of days changes, so that picking
#' another sensor draws it without downloading again, and renders the chart of
#' the picked sensor. When the server cannot be reached, or the device does
#' not have the sensor, the chart says so.
#' @param id Character. Module namespace id, must match the id used in
#'   [mod_timeseries_ui()].
#' @return None. Called for its side effect of registering the module server.
#' @keywords internal
#' @examples
#' \dontrun{
#' # inside app_server():
#' function(input, output, session) {
#'   mod_timeseries_server("timeseries")
#' }
#' }
mod_timeseries_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    timeseries_data <- reactive({
      start_time <- format(Sys.time() - as.numeric(input$days) * 60 * 60 * 24, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
      get_data(start_time = start_time, end_time = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), urlq = input$server_timeseries)
    })
    output$plot <- plotly::renderPlotly({
      filtered_df <- timeseries_data()
      validate(need(filtered_df, paste("The Prometheus server", input$server_timeseries, "cannot be reached right now")))
      req(input$sensor)
      variable <- sensor_label(input$sensor)
      # get_data() leaves out the sensors whose readings do not change, those the device does not have
      validate(need(
        variable %in% names(filtered_df),
        paste(variable, "has no readings that change in this period: this device may not have that sensor")
      ))
      scale <- if (input$sensor == "humidity") "Relative humidity (%)" else metric_units[[input$sensor]]
      plot_time_series(data = filtered_df, variable = variable, scale = scale)
    })
  })
}
