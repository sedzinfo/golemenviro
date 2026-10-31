test_that("the time series and the gauges build for every sensor", {
  for (variable in c("Temperature", "Humidity", "PM2.5")) {
    expect_no_error(plotly::plotly_build(plot_time_series(readings, variable, k = 3)))
    expect_no_error(plotly::plotly_build(plot_gauge(readings, variable)))
  }
})

test_that("a gauge without an ideal range shows the last reading, scaled to all the readings", {
  gas <- transform(readings, NH3 = c(100, 110, 120, 130, 140))
  gauge <- plotly::plotly_build(plot_gauge(gas, "NH3"))$x$data[[1]]
  sd_nh3 <- sd(gas$NH3)
  expect_equal(gauge$value, 140)
  expect_equal(gauge$gauge$axis$range, c(100 - sd_nh3, 140 + sd_nh3))
  expect_equal(gauge$gauge$steps[[1]]$range, c(120 - sd_nh3, 120 + sd_nh3))
  expect_equal(gauge$delta$reference, 120)
})

test_that("the summary of a time series shows the mean and the standard deviation", {
  plot <- plotly::plotly_build(plot_time_series(readings, "Temperature", k = 3))
  summary <- plot$x$layout$annotations[[1]]$text
  expect_match(summary, paste0(intToUtf8(0x03bc), ": 22"), fixed = TRUE)
  expect_match(summary, paste0(intToUtf8(0x03c3), ":"), fixed = TRUE)
})

test_that("the daily pattern has a row per hour and a column per day, and turns its colors round in dark mode", {
  hourly <- expand.grid(hour = 0:23, date = as.Date("2023-11-01") + 0:2)
  hourly$value <- hourly$hour
  hourly <- hourly[-5, ]
  light <- plotly::plotly_build(plot_daily_pattern(hourly, "Temperature", "C"))$x$data[[1]]
  dark <- plotly::plotly_build(plot_daily_pattern(hourly, "Temperature", "C", "dark"))$x$data[[1]]
  expect_equal(dim(light$z), c(24, 3))
  expect_true(is.na(light$z[5, 1]))
  expect_match(light$text[5, 1], "no readings")
  expect_equal(light$z[18, 2], 17)
  expect_equal(light$colorscale[[1]][[2]], dark$colorscale[[5]][[2]])
  expect_equal(light$colorscale[[5]][[2]], dark$colorscale[[1]][[2]])
})

test_that("a typical day has the median of each hour between its quartiles", {
  hourly <- expand.grid(hour = 0:23, date = as.Date("2023-11-01") + 0:3)
  hourly$value <- hourly$hour + rep(1:4, each = 24)
  for (mode in c("light", "dark")) {
    traces <- plotly::plotly_build(plot_average_day(hourly, "Temperature", "C", mode))$x$data
    expect_length(traces, 3)
    expect_equal(traces[[3]]$y[1], stats::median(1:4))
    expect_true(all(traces[[1]]$y <= traces[[3]]$y & traces[[3]]$y <= traces[[2]]$y))
  }
})

test_that("the daily averages show the guideline, which the axis always reaches", {
  daily <- data.frame(date = as.Date("2023-11-01") + 0:2, value = c(3, 5, 4), hours = c(24L, 20L, 24L))
  for (mode in c("light", "dark")) {
    built <- plotly::plotly_build(plot_daily_means(daily, "PM2.5", 15, mode))$x
    expect_equal(built$layout$shapes[[1]]$y0, 15)
    expect_gt(built$layout$yaxis$range[[2]], 15)
    expect_match(built$data[[1]]$text[2], "20 hours with readings")
  }
})
