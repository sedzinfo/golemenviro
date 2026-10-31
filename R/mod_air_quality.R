##########################################################################################
#
##########################################################################################
#' @title Air Quality module - UI
#' @description A server and a period to pick, the number of days of the period
#' above the guideline of the World Health Organization for the average of a
#' day, for PM2.5 and PM10, and a bar chart of their daily averages, each with
#' a full screen button (see `inst/app/www/plot_zoom.js`).
#' @param id Character. Module namespace id.
#' @param prometheus_url Prometheus query_range urls to choose from.
#' @return A `tagList` of Shiny UI elements.
#' @keywords internal
#' @examples
#' \dontrun{
#' shiny::fluidPage(golemenviro:::mod_air_quality_ui("air_quality", "http://localhost:9090/api/v1/query_range"))
#' }
mod_air_quality_ui <- function(id, prometheus_url) {
  ns <- NS(id)
  # the periods to choose from, in days
  periods <- c("1 month" = 30, "3 months" = 91, "6 months" = 182, "1 year" = 365)
  tile <- function(output) {
    shinydashboard::box(width = 6, class = "sensor-box", output)
  }
  tagList(
    fluidRow(
      column(width = 4, selectInput(ns("server"), label = "Server", choices = c(prometheus_url), selected = prometheus_url[1], width = "600px")),
      column(width = 4, selectInput(ns("days"), label = "Period", choices = periods, selected = 30))
    ),
    fluidRow(class = "aq-tiles", tile(uiOutput(ns("summary_pm25"))), tile(uiOutput(ns("summary_pm10")))),
    fluidRow(div(
      class = "plotly-full-screen",
      column(width = 12, class = "sensor-box", plotly::plotlyOutput(ns("plot_pm25"), height = "340px")),
      column(width = 12, class = "sensor-box", plotly::plotlyOutput(ns("plot_pm10"), height = "340px"))
    ))
  )
}
##########################################################################################
#
##########################################################################################
#' @title Air Quality module - server
#' @description Downloads the daily averages of PM2.5 and PM10 when the server or
#' the period changes, and shows how many days were above the guideline of the
#' World Health Organization for a day, the average of the period against the
#' guideline for a year, and the bars of the days. When the server cannot be
#' reached, or the device has no particle sensor, the tab says so.
#' @param id Character. Module namespace id, must match the id used in
#'   [mod_air_quality_ui()].
#' @param dark_mode Reactive returning `"light"` or `"dark"`, the mode of the
#'   app, for the colors of the bars.
#' @return None. Called for its side effect of registering the module server.
#' @keywords internal
#' @examples
#' \dontrun{
#' # inside app_server():
#' mod_air_quality_server("air_quality", reactive(if (isTRUE(input$dark_mode)) "dark" else "light"))
#' }
mod_air_quality_server <- function(id, dark_mode) {
  moduleServer(id, function(input, output, session) {
    daily <- reactive({
      req(input$server, input$days)
      lapply(stats::setNames(who_guidelines$metric, who_guidelines$metric), function(metric) {
        get_daily(input$server, metric, as.numeric(input$days))
      })
    })
    # the days of one sensor, or the reason they cannot be shown
    days_of <- function(metric) {
      days <- daily()[[metric]]
      label <- sensor_label(metric)
      validate(need(!is.null(days), paste("The Prometheus server", input$server, "cannot be reached right now")))
      validate(need(nrow(days) > 0, paste("The server has no", label, "readings for whole days in this period")))
      validate(need(
        nrow(days) == 1 || isTRUE(stats::sd(days$value) > 0),
        paste(label, "does not change: this device has no particle sensor")
      ))
      days
    }
    summary_of <- function(metric) {
      renderUI({
        days <- days_of(metric)
        guideline <- who_guidelines[who_guidelines$metric == metric, ]
        div(
          class = "aq-tile",
          tags$h4(sensor_label(metric)),
          p(class = "aq-number", sum(days$value > guideline$day), span(class = "aq-of", paste("of", nrow(days), if (nrow(days) == 1) "day" else "days"))),
          p(paste0(
            "above the guideline of the World Health Organization for a day, ", guideline$day, " ", micrograms_m3,
            ", which allows 3 to 4 such days in a year."
          )),
          p(paste0(
            "The average of the period is ", formatC(mean(days$value), format = "f", digits = 1), " ", micrograms_m3,
            "; the guideline for a year is ", guideline$year, "."
          ))
        )
      })
    }
    output$summary_pm25 <- summary_of("PM25")
    output$summary_pm10 <- summary_of("PM10")
    output$plot_pm25 <- plotly::renderPlotly(plot_daily_means(days_of("PM25"), "PM2.5", who_guidelines$day[who_guidelines$metric == "PM25"], dark_mode()))
    output$plot_pm10 <- plotly::renderPlotly(plot_daily_means(days_of("PM10"), "PM10", who_guidelines$day[who_guidelines$metric == "PM10"], dark_mode()))
  })
}
