##########################################################################################
#
##########################################################################################
#' @title The text of the About tab
#' @description Reads `inst/app/about.md` and fills in the time zone of the app,
#' in which the tabs show the times.
#' @return The Markdown text, as one string.
#' @keywords internal
#' @examples
#' cat(substr(golemenviro:::about_text(), 1, 300))
about_text <- function() {
  text <- paste(readLines(app_sys("app/about.md"), encoding = "UTF-8"), collapse = "\n")
  gsub("{{timezone}}", app_time_zone(), text, fixed = TRUE)
}
##########################################################################################
#
##########################################################################################
#' @title About module - UI
#' @description What each tab shows, what the sensors measure and how to read
#' their numbers, from [about_text()].
#' @param id Character. Module namespace id.
#' @return A `div` of Shiny UI elements.
#' @keywords internal
#' @examples
#' \dontrun{
#' shiny::fluidPage(golemenviro:::mod_about_ui("about"))
#' }
mod_about_ui <- function(id) {
  div(class = "about", markdown(about_text()))
}
