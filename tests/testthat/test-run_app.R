test_that("pimoroni() passes the servers to the app as a golem option", {
  app <- pimoroni(prometheus_url = c("http://a", "http://b"))
  expect_s3_class(app, "shiny.appobj")
  expect_equal(app$appOptions$golem_options$prometheus_url, c("http://a", "http://b"))
})

test_that("Google Analytics and its cookie banner are in the page only when asked for", {
  page <- function(analytics) htmltools::renderTags(app_ui(NULL, analytics = analytics))
  with <- page(TRUE)
  expect_match(with$head, "https://sedzinfo.github.io/consent.js", fixed = TRUE)
  expect_match(with$html, "#cookie-settings", fixed = TRUE)
  without <- page(FALSE)
  expect_no_match(without$head, "consent.js", fixed = TRUE)
  expect_no_match(without$html, "cookie-settings", fixed = TRUE)
})

test_that("the head has the description and the address of the live app for link previews", {
  head <- htmltools::renderTags(app_ui(NULL))$head
  expect_match(head, paste0("<meta name=\"description\" content=\"", app_meta$description, "\"/>"), fixed = TRUE)
  expect_match(head, "<meta property=\"og:url\" content=\"https://sedzinfo-golemenviro.share.connect.posit.cloud/\"/>", fixed = TRUE)
  # search engines cut descriptions longer than about 160 characters
  expect_lte(nchar(app_meta$description), 160)
})

test_that("the pickers of both tabs offer the servers", {
  current <- as.character(mod_current_ui("current", c("http://a", "http://b")))
  timeseries <- as.character(mod_timeseries_ui("timeseries", c("http://a", "http://b")))
  for (ui in c(current, timeseries)) {
    expect_match(ui, "<option value=\"http://a\" selected>http://a</option>", fixed = TRUE)
    expect_match(ui, "<option value=\"http://b\">http://b</option>", fixed = TRUE)
  }
})
