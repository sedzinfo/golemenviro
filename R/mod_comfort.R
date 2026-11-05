##########################################################################################
#
##########################################################################################
#' @title Comfort module - UI
#' @description A server and a period to pick, a chart of the temperature
#' against the humidity of every hour of the period over the comfortable ranges
#' (see [plot_comfort()]), and under it the shares of the hours that were too
#' warm, too cool, too dry or too humid. The chart has a full screen button
#' (see `inst/app/www/plot_zoom.js`).
#' @param id Character. Module namespace id.
#' @param prometheus_url Prometheus query_range urls to choose from.
#' @return A `tagList` of Shiny UI elements.
#' @keywords internal
#' @examples
#' \dontrun{
#' shiny::fluidPage(golemenviro:::mod_comfort_ui("comfort", "http://localhost:9090/api/v1/query_range"))
#' }
mod_comfort_ui <- function(id, prometheus_url) {
  ns <- NS(id)
  # the periods to choose from, in days
  periods <- c("1 week" = 7, "2 weeks" = 14, "1 month" = 30, "3 months" = 91, "6 months" = 182, "1 year" = 365)
  tagList(
    fluidRow(
      column(width = 8, selectInput(ns("server"), label = "Server", choices = c(prometheus_url), selected = prometheus_url[1], width = "600px")),
      column(width = 4, selectInput(ns("days"), label = "Period", choices = periods, selected = 30))
    ),
    fluidRow(div(
      class = "plotly-full-screen",
      column(width = 12, class = "sensor-box", plotly::plotlyOutput(ns("comfort"), height = "600px"))
    )),
    fluidRow(column(width = 12, uiOutput(ns("summary"))))
  )
}
##########################################################################################
#
##########################################################################################
#' @title Comfort module - server
#' @description Downloads the hourly averages of temperature and humidity and
#' draws them against the comfortable ranges, or says why it cannot: the server
#' cannot be reached, or it has no readings of one of the two in that period.
#' @param id Character. Module namespace id, must match the id used in
#'   [mod_comfort_ui()].
#' @param dark_mode Reactive returning `"light"` or `"dark"`, the mode of the
#'   app, for the colors of the chart.
#' @return None. Called for its side effect of registering the module server.
#' @keywords internal
#' @examples
#' \dontrun{
#' # inside app_server():
#' mod_comfort_server("comfort", reactive(if (isTRUE(input$dark_mode)) "dark" else "light"))
#' }
mod_comfort_server <- function(id, dark_mode) {
  moduleServer(id, function(input, output, session) {
    # downloads live in reactives, so switching the mode redraws without downloading again
    temperature <- reactive({
      req(input$server, input$days)
      get_hourly(input$server, "temperature", as.numeric(input$days))
    })
    humidity <- reactive({
      req(input$server, input$days)
      get_hourly(input$server, "humidity", as.numeric(input$days))
    })
    drawable <- reactive({
      validate(
        need(!is.null(temperature()) && !is.null(humidity()), paste("The Prometheus server", input$server, "cannot be reached right now")),
        need(NROW(temperature()) > 0, "The server has no Temperature readings in this period"),
        need(NROW(humidity()) > 0, "The server has no Humidity readings in this period")
      )
      list(temperature = temperature(), humidity = humidity())
    })
    output$comfort <- plotly::renderPlotly({
      plot_comfort(drawable()$temperature, drawable()$humidity, dark_mode())
    })
    output$summary <- renderUI({
      s <- comfort_summary(drawable()$temperature, drawable()$humidity)
      req(s$hours > 0)
      p(
        class = "text-muted",
        sprintf(
          "Outside the comfort zone: too warm %.0f%%, too cool %.0f%%, too dry %.0f%%, too humid %.0f%% of the hours (an hour can be both too warm and too dry).",
          s$too_warm, s$too_cool, s$too_dry, s$too_humid
        )
      )
    })
  })
}
