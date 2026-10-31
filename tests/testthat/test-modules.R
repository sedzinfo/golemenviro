test_that("the time series tab draws the picked sensor, and says when the device does not have it", {
  local_mocked_bindings(get_data = function(...) readings)
  testServer(mod_timeseries_server, {
    session$setInputs(server_timeseries = "http://x", days = "7", sensor = "temperature")
    expect_no_error(output$plot)
    session$setInputs(sensor = "PM25")
    expect_no_error(output$plot)
    session$setInputs(sensor = "NH3")
    expect_error(output$plot, "NH3 has no readings that change in this period")
  })
})

test_that("the current tab shows the last reading of each sensor", {
  local_mocked_bindings(get_data = function(...) readings)
  testServer(mod_current_server, {
    session$setInputs(server_gauge = "http://x")
    expect_equal(nrow(last_reading()), 1)
    expect_equal(last_reading()$Temperature, 23)
    expect_no_error(output$gauge_temperature)
  })
})

test_that("the current tab gives the gauges all the readings, not only the last", {
  rows <- 0
  local_mocked_bindings(
    get_data = function(...) readings,
    plot_gauge = function(data, variable) {
      rows <<- nrow(data)
      plotly::plot_ly(type = "indicator", mode = "number", value = 1)
    }
  )
  testServer(mod_current_server, {
    session$setInputs(server_gauge = "http://x")
    output$gauge_temperature
    expect_equal(rows, nrow(readings))
  })
})

test_that("the current tab shows when the last reading was taken, in red when it is old", {
  # the saved readings are from 2023
  local_mocked_bindings(get_data = function(...) readings)
  testServer(mod_current_server, {
    session$setInputs(server_gauge = "http://x")
    expect_match(output$last_date$html, "reading-old", fixed = TRUE)
    expect_match(output$last_date$html, "Last reading: 2023-11-1\\d .* days ago")
  })
  # the same readings, as if the last one had come 5 minutes ago
  local_mocked_bindings(get_data = function(...) transform(readings, Date = Sys.time() - 60 * c(45, 35, 25, 15, 5)))
  testServer(mod_current_server, {
    session$setInputs(server_gauge = "http://x")
    expect_match(output$last_date$html, "Last reading:", fixed = TRUE)
    expect_no_match(output$last_date$html, "reading-old", fixed = TRUE)
  })
})

test_that("the current tab downloads the readings again every 5 minutes", {
  downloads <- 0
  local_mocked_bindings(get_data = function(...) {
    downloads <<- downloads + 1
    readings
  })
  testServer(mod_current_server, {
    session$setInputs(server_gauge = "http://x")
    last_reading()
    session$elapse(4 * 60 * 1000)
    last_reading()
    expect_equal(downloads, 1)
    session$elapse(60 * 1000)
    last_reading()
    expect_equal(downloads, 2)
  })
})

test_that("both tabs say when the server cannot be reached", {
  local_mocked_bindings(get_data = function(...) NULL)
  testServer(mod_timeseries_server, {
    session$setInputs(server_timeseries = "http://x", days = "7", sensor = "temperature")
    expect_error(output$plot, "The Prometheus server http://x cannot be reached right now")
  })
  testServer(mod_current_server, {
    session$setInputs(server_gauge = "http://x")
    expect_error(output$gauge_temperature, "The Prometheus server http://x cannot be reached right now")
  })
})

test_that("the time series tab downloads once per change of server or days, not of sensor", {
  downloads <- 0
  local_mocked_bindings(get_data = function(...) {
    downloads <<- downloads + 1
    readings
  })
  testServer(mod_timeseries_server, {
    session$setInputs(server_timeseries = "http://x", days = "1", sensor = "temperature")
    for (days in c("2", "3", "4")) session$setInputs(days = days)
    for (sensor in c("humidity", "PM25", "temperature")) session$setInputs(sensor = sensor)
    output$plot
    expect_equal(downloads, 4)
  })
})

test_that("the daily pattern tab says why it cannot draw a sensor", {
  light <- reactive("light")
  local_mocked_bindings(get_hourly = function(...) NULL)
  testServer(mod_daily_pattern_server, args = list(dark_mode = light), {
    session$setInputs(server = "http://x", sensor = "temperature", days = "30")
    expect_error(output$heatmap, "cannot be reached")
  })
  local_mocked_bindings(get_hourly = function(...) data.frame(date = as.Date("2023-11-01"), hour = 0:23, value = 5))
  testServer(mod_daily_pattern_server, args = list(dark_mode = light), {
    session$setInputs(server = "http://x", sensor = "NH3", days = "30")
    expect_error(output$heatmap, "NH3 does not change")
  })
})

test_that("the daily pattern tab draws the heatmap and the typical day", {
  hourly <- expand.grid(hour = 0:23, date = as.Date("2023-11-01") + 0:6)
  hourly$value <- 20 + hourly$hour / 10
  local_mocked_bindings(get_hourly = function(...) hourly)
  testServer(mod_daily_pattern_server, args = list(dark_mode = reactive("dark")), {
    session$setInputs(server = "http://x", sensor = "PM25", days = "7")
    expect_no_error(output$heatmap)
    expect_no_error(output$average_day)
    expect_equal(label(), "PM2.5")
  })
})

test_that("the about tab explains every tab and every sensor", {
  page <- htmltools::renderTags(mod_about_ui("about"))$html
  for (tab in c("Current", "Time Series", "Daily Pattern", "Air Quality")) {
    expect_match(page, paste0(">", tab, "</h3>"), fixed = TRUE, label = tab)
  }
  for (sensor in sensor_label(metrics)) {
    expect_match(page, sensor, fixed = TRUE, label = sensor)
  }
  expect_no_match(page, "{{", fixed = TRUE)
})

test_that("the charts of the time series and daily pattern tabs get the full screen button", {
  # plot_zoom.js adds the button to the plotly charts inside .plotly-full-screen
  timeseries <- htmltools::renderTags(mod_timeseries_ui("timeseries", "http://x"))$html
  daily_pattern <- htmltools::renderTags(mod_daily_pattern_ui("daily_pattern", "http://x"))$html
  expect_match(timeseries, "(?s)plotly-full-screen.*id=\"timeseries-plot\"", perl = TRUE)
  expect_match(daily_pattern, "(?s)plotly-full-screen.*id=\"daily_pattern-heatmap\".*id=\"daily_pattern-average_day\"", perl = TRUE)
})

test_that("the air quality tab counts the days above the guideline of each sensor", {
  fixture <- data.frame(date = as.Date("2023-11-01") + 0:3, value = c(10, 20, 30, 12), hours = 24L)
  local_mocked_bindings(get_daily = function(...) fixture)
  testServer(mod_air_quality_server, args = list(dark_mode = reactive("light")), {
    session$setInputs(server = "http://x", days = "30")
    # PM2.5 above 15 on two days, PM10 never above 45
    expect_match(output$summary_pm25$html, "aq-number\">\\s*2\\s*<span class=\"aq-of\">of 4 days")
    expect_match(output$summary_pm10$html, "aq-number\">\\s*0\\s*<span class=\"aq-of\">of 4 days")
    expect_match(output$summary_pm25$html, "average of the period is 18.0", fixed = TRUE)
    expect_no_error(output$plot_pm25)
  })
})

test_that("the air quality tab says when the device has no particle sensor, or cannot be reached", {
  local_mocked_bindings(get_daily = function(...) data.frame(date = as.Date("2023-11-01") + 0:3, value = 0, hours = 24L))
  testServer(mod_air_quality_server, args = list(dark_mode = reactive("light")), {
    session$setInputs(server = "http://x", days = "30")
    expect_error(output$plot_pm25, "PM2.5 does not change: this device has no particle sensor")
  })
  local_mocked_bindings(get_daily = function(...) NULL)
  testServer(mod_air_quality_server, args = list(dark_mode = reactive("light")), {
    session$setInputs(server = "http://x", days = "30")
    expect_error(output$summary_pm10, "cannot be reached")
  })
})
