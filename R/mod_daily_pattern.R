##########################################################################################
#
##########################################################################################
#' @title Daily Pattern module - UI
#' @description A server, a sensor and a period to pick, a heatmap of the hourly
#' averages of that sensor, a column per day and a row per hour, and below it a
#' typical day: the median of each hour and the range of its middle half. Each
#' chart has a full screen button (see `inst/app/www/plot_zoom.js`).
#' @param id Character. Module namespace id.
#' @param prometheus_url Prometheus query_range urls to choose from.
#' @return A `tagList` of Shiny UI elements.
#' @keywords internal
#' @examples
#' \dontrun{
#' shiny::fluidPage(golemenviro:::mod_daily_pattern_ui("daily_pattern", "http://localhost:9090/api/v1/query_range"))
#' }
mod_daily_pattern_ui <- function(id, prometheus_url) {
  ns <- NS(id)
  # the periods to choose from, in days
  periods <- c("1 week" = 7, "2 weeks" = 14, "1 month" = 30, "3 months" = 91, "6 months" = 182, "1 year" = 365)
  tagList(
    fluidRow(
      column(width = 4, selectInput(ns("server"), label = "Server", choices = c(prometheus_url), selected = prometheus_url[1], width = "600px")),
      column(width = 4, selectInput(ns("sensor"), label = "Sensor", choices = stats::setNames(metrics, sensor_label(metrics)), selected = "temperature")),
      column(width = 4, selectInput(ns("days"), label = "Period", choices = periods, selected = 30))
    ),
    fluidRow(div(
      class = "plotly-full-screen",
      column(width = 12, class = "sensor-box", plotly::plotlyOutput(ns("heatmap"), height = "480px")),
      column(width = 12, class = "sensor-box", plotly::plotlyOutput(ns("average_day"), height = "340px"))
    ))
  )
}
##########################################################################################
#
##########################################################################################
#' @title Daily Pattern module - server
#' @description Downloads the hourly averages of the picked sensor and draws
#' them, or says why it cannot: the server cannot be reached, it has no
#' readings of the sensor in that period, or they never change, as for the gas
#' sensors of an Enviro, which has none.
#' @param id Character. Module namespace id, must match the id used in
#'   [mod_daily_pattern_ui()].
#' @param dark_mode Reactive returning `"light"` or `"dark"`, the mode of the
#'   app, for the colors of the heatmap.
#' @return None. Called for its side effect of registering the module server.
#' @keywords internal
#' @examples
#' \dontrun{
#' # inside app_server():
#' mod_daily_pattern_server("daily_pattern", reactive(if (isTRUE(input$dark_mode)) "dark" else "light"))
#' }
mod_daily_pattern_server <- function(id, dark_mode) {
  moduleServer(id, function(input, output, session) {
    # downloads live in a reactive, so switching the mode redraws without downloading again
    hourly <- reactive({
      req(input$server, input$sensor, input$days)
      get_hourly(input$server, input$sensor, as.numeric(input$days))
    })
    label <- reactive(sensor_label(input$sensor))
    drawable <- reactive({
      validate(
        need(!is.null(hourly()), paste("The Prometheus server", input$server, "cannot be reached right now")),
        need(NROW(hourly()) > 0, paste("The server has no", label(), "readings in this period"))
      )
      validate(need(
        isTRUE(stats::sd(hourly()$value, na.rm = TRUE) > 0),
        paste(label(), "does not change: this device has no such sensor")
      ))
      hourly()
    })
    output$heatmap <- plotly::renderPlotly({
      plot_daily_pattern(drawable(), label(), metric_units[[input$sensor]], dark_mode())
    })
    output$average_day <- plotly::renderPlotly({
      plot_average_day(drawable(), label(), metric_units[[input$sensor]], dark_mode())
    })
  })
}
