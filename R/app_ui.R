##########################################################################################
#
##########################################################################################
#' The application User-Interface
#'
#' A navbar page with the Current tab, gauges with the latest readings, the
#' Time Series tab, a chart of the picked sensor, the Daily Pattern tab, the
#' hourly averages of one sensor by day and hour, the Air Quality tab, the daily
#' averages of the particles against the guidelines of the World Health
#' Organization, and the About tab. The servers to choose from are the
#' `prometheus_url` given to [pimoroni()].
#'
#' @param request Internal parameter for `{shiny}`. DO NOT REMOVE.
#' @param analytics `TRUE` to add Google Analytics, with its cookie banner
#'   (see `analytics_resources()`) and a footer with the links of the banner
#'   (see `analytics_footer()`).
#'
#' @import shiny
#' @noRd
#'
#' @examples
#' \dontrun{
#' shiny::shinyApp(ui = app_ui, server = app_server)
#' }
app_ui <- function(request, analytics = FALSE) {
  prometheus_url <- golem::get_golem_options("prometheus_url")
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    if (analytics) tags$head(analytics_resources()),
    # Application UI logic
    navbarPage(
      "Prometheus Enviro Data Visualization",
      footer = if (analytics) analytics_footer(),
      tabPanel("Current", mod_current_ui("current", prometheus_url)),
      tabPanel("Time Series", mod_timeseries_ui("timeseries", prometheus_url)),
      tabPanel("Daily Pattern", mod_daily_pattern_ui("daily_pattern", prometheus_url)),
      tabPanel("Air Quality", mod_air_quality_ui("air_quality", prometheus_url)),
      tabPanel("About", mod_about_ui("about"))
    )
  )
}
##########################################################################################
#
##########################################################################################
#' Add external resources to the application
#'
#' Internally used to add the favicon, the Font Awesome icons of the full
#' screen buttons, and the CSS and JavaScript files of `inst/app/www` inside
#' the Shiny application: those of the charts (`custom.css`, `plot_zoom.js`),
#' of the analytics (`analytics.css`, `analytics.js`) and of the dark mode
#' (`dark_mode.css`, `dark_mode.js`). A file put in that folder is added
#' without any change here.
#'
#' @import shiny
#' @importFrom golem add_resource_path favicon bundle_resources
#' @noRd
#'
#' @examples
#' \dontrun{
#' # called from inside app_ui():
#' shiny::tagList(golem_add_external_resources(), shiny::fluidPage())
#' }
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(ext = "svg"),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "Prometheus Enviro Data Visualization"
    ),
    # the Font Awesome icons of the full screen buttons of the charts
    htmltools::htmlDependencies(icon("expand"))
  )
}
