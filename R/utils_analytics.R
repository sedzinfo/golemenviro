##########################################################################################
#
##########################################################################################
#' Address of the cookie banner shared by the sites of sedzinfo.github.io
#'
#' @noRd
consent_script <- "https://sedzinfo.github.io/consent.js"
##########################################################################################
#
##########################################################################################
#' Address of the files shared by the Shiny apps, on sedzinfo.github.io
#'
#' The scripts and stylesheets that several apps use (the Google Analytics events, the
#' style of the cookie banner on Bootstrap 3, the dark mode) are kept once,
#' in the shiny folder of the sedzinfo.github.io repository, and each app loads
#' them from there: a fix reaches every app without deploying it again.
#'
#' @noRd
shared_url <- "https://sedzinfo.github.io/shiny/"
##########################################################################################
#
##########################################################################################
#' The stylesheet shared by the Shiny apps
#'
#' \code{https://sedzinfo.github.io/shiny/apps.css}, as a link for the head of the page, before
#' the app's own stylesheets. Shiny puts the head after the stylesheets of Bootstrap and of the
#' inputs, so the page loads those, then this, then the app's own, which can override it.
#'
#' @noRd
shared_css <- function() {
  tags$link(rel = "stylesheet", href = paste0(shared_url, "apps.css"))
}
##########################################################################################
#
##########################################################################################
#' Google Analytics for the public deployment
#'
#' Loads the cookie banner shared with the sites of sedzinfo.github.io, which
#' loads Google Analytics only after the visitor accepts, and two files shared
#' by the apps: the style of the banner on Bootstrap 3, which lacks most of the
#' Bootstrap 5 classes of the banner (`analytics.css`), and the script that
#' reports the tabs as pages (`analytics.js`).
#'
#' @return A `tagList` for the head of the page.
#'
#' @noRd
#'
#' @examples
#' golemenviro:::analytics_resources()
analytics_resources <- function() {
  tagList(
    tags$script(src = consent_script, defer = NA),
    tags$link(rel = "stylesheet", href = paste0(shared_url, "analytics.css")),
    tags$script(src = paste0(shared_url, "analytics.js"))
  )
}
##########################################################################################
#
##########################################################################################
#' Footer with the links of the cookie banner
#'
#' "Cookie settings" opens the banner again, so that visitors can change their
#' choice at any time, as the privacy note promises; "Privacy" opens that
#' note.
#'
#' @return A `div` for the bottom of the page.
#'
#' @noRd
#'
#' @examples
#' golemenviro:::analytics_footer()
analytics_footer <- function() {
  div(
    class = "analytics-footer",
    tags$a(href = "#cookie-settings", "Cookie settings"),
    HTML(" &middot; "),
    tags$a(href = "https://sedzinfo.github.io/privacy.html", "Privacy")
  )
}
