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

test_that("the files shared by the apps (dark_mode.js, analytics.js, analytics.css) come from sedzinfo.github.io, not from inst/app/www", {
  head <- htmltools::renderTags(app_ui(NULL, analytics = TRUE))$head
  expect_match(head, "https://sedzinfo.github.io/shiny/dark_mode.js", fixed = TRUE)
  expect_no_match(head, "www/dark_mode.js", fixed = TRUE)
  expect_match(head, "https://sedzinfo.github.io/shiny/analytics.js", fixed = TRUE)
  expect_no_match(head, "www/analytics.js", fixed = TRUE)
  expect_match(head, "https://sedzinfo.github.io/shiny/analytics.css", fixed = TRUE)
  expect_no_match(head, "www/analytics.css", fixed = TRUE)
})

test_that("the stylesheet shared by the apps is in the page, before the app's own", {
  rendered <- htmltools::renderTags(app_ui(NULL))
  # as shiny draws the head: the dependencies first (the shared stylesheet is one; those with only
  # a local folder, such as jQuery, shiny serves itself), then the rest of the head
  deps <- Filter(function(d) !is.null(d$src$href), htmltools::resolveDependencies(rendered$dependencies))
  page <- paste(htmltools::renderDependencies(deps, "href"), rendered$head)
  shared <- regexpr("https://sedzinfo.github.io/shiny/apps.css", page, fixed = TRUE)
  expect_gt(shared, 0)
  own <- regexpr("href=\"www/[A-Za-z0-9_.-]+\\.css\"", page)
  if (own > 0) expect_lt(shared, own)
})
