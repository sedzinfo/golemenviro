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
      # on phones the tabs fold into a menu behind a button (custom.css, navbar.js); a navbar that
      # does not fold stacks them, a third of the screen of a phone above every tab
      collapsible = TRUE,
      footer = if (analytics) analytics_footer(),
      tabPanel("Current", mod_current_ui("current", prometheus_url)),
      tabPanel("Time Series", mod_timeseries_ui("timeseries", prometheus_url)),
      tabPanel("Daily Pattern", mod_daily_pattern_ui("daily_pattern", prometheus_url)),
      tabPanel("Comfort", mod_comfort_ui("comfort", prometheus_url)),
      tabPanel("Air Quality", mod_air_quality_ui("air_quality", prometheus_url)),
      tabPanel("About", mod_about_ui("about"))
    )
  )
}
##########################################################################################
#
##########################################################################################
#' Address and description of the live app, for search engines and link previews
#'
#' Used by `golem_add_external_resources()` for the description that search
#' engines show and the Open Graph tags of the preview that other sites show
#' for a link to the app. `title` is the window title that `app_ui()` gives the
#' page, and `image` the first screenshot of the app in the README.
#'
#' @noRd
app_meta <- list(
  url = "https://sedzinfo-golemenviro.share.connect.posit.cloud/",
  title = "Prometheus Enviro Data Visualization",
  description = "Real-time gauges and time series charts of the readings of Pimoroni Enviro and Enviro+ sensors exported to Prometheus.",
  image = "https://raw.githubusercontent.com/sedzinfo/golemenviro/main/screenshots/current.png"
)
##########################################################################################
#
##########################################################################################
#' Add external resources to the application
#'
#' Internally used to add the description and Open Graph tags of `app_meta`,
#' the favicon, the Font Awesome icons of the full screen buttons, and the CSS
#' and JavaScript files of `inst/app/www` inside the Shiny application: those
#' of the charts (`custom.css`, `plot_zoom.js`), of the menu of the tabs on
#' phones (`navbar.js`) and of the dark mode (`dark_mode.css`). A file put in
#' that folder is added without any change here. The script of the dark mode
#' (`dark_mode.js`) is shared by the apps: it comes from sedzinfo.github.io
#' (`shared_url`), as do the files of the analytics (`analytics_resources()`).
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
    tags$meta(name = "description", content = app_meta$description),
    tags$meta(property = "og:type", content = "website"),
    tags$meta(property = "og:site_name", content = "sedzinfo"),
    tags$meta(property = "og:title", content = app_meta$title),
    tags$meta(property = "og:description", content = app_meta$description),
    tags$meta(property = "og:url", content = app_meta$url),
    tags$meta(property = "og:image", content = app_meta$image),
    tags$meta(name = "twitter:card", content = "summary_large_image"),
    favicon(ext = "svg"),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "Prometheus Enviro Data Visualization"
    ),
    tags$script(src = paste0(shared_url, "dark_mode.js")),
    # the Font Awesome icons of the full screen buttons of the charts
    htmltools::htmlDependencies(icon("expand"))
  )
}
