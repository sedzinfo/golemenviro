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

test_that("with mid, the daily pattern is blue below it, white at it and red above it", {
  hourly <- expand.grid(hour = 0:23, date = as.Date("2023-11-01") + 0:2)
  hourly$value <- 20 + hourly$hour / 2 # 20 to 31.5
  heat <- plotly::plotly_build(plot_daily_pattern(hourly, "Temperature", "C", mid = 24))$x$data[[1]]
  # the range is symmetric around mid, so white falls exactly on it
  expect_equal(mean(c(heat$zmin, heat$zmax)), 24)
  scale <- vapply(heat$colorscale, function(s) s[[2]], character(1))
  expect_equal(scale[c(1, 3, 5)], c("#2166AC", "#F7F7F7", "#B2182B"))
})

test_that("metric_mid has a value or NA for every metric, the WHO guideline for particles", {
  expect_setequal(names(metric_mid), metrics)
  expect_equal(metric_mid[["PM25"]], who_guidelines$day[who_guidelines$metric == "PM25"])
  expect_equal(metric_mid[["PM10"]], who_guidelines$day[who_guidelines$metric == "PM10"])
  expect_true(is.na(metric_mid[["PM1"]]))
})

test_that("red_steps matches blue_steps: five colors, light to dark", {
  expect_length(red_steps, length(blue_steps))
  lightness <- function(x) colSums(grDevices::col2rgb(x))
  expect_true(all(diff(lightness(red_steps)) < 0))
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

test_that("comfort_summary() counts the hours in the zone and on each side of it", {
  hours <- expand.grid(hour = 0:3, date = as.Date("2023-11-01"))
  temperature <- transform(hours, value = c(22, 27, 18, 22))
  humidity <- transform(hours, value = c(50, 35, 50, 70))
  s <- comfort_summary(temperature, humidity)
  expect_equal(s$hours, 4)
  expect_equal(s$comfortable, 25) # only the first hour
  expect_equal(c(s$too_warm, s$too_cool, s$too_dry, s$too_humid), c(25, 25, 25, 25))
  # an hour without humidity does not count
  expect_equal(comfort_summary(temperature, humidity[-4, ])$hours, 3)
})

test_that("plot_comfort() draws a point per hour over the comfort zone", {
  hours <- expand.grid(hour = 0:23, date = as.Date("2023-11-01") + 0:2)
  temperature <- transform(hours, value = 22 + hour / 4)
  humidity <- transform(hours, value = 45)
  built <- plotly::plotly_build(plot_comfort(temperature, humidity))$x
  expect_length(built$data[[1]]$x, 72)
  zone <- built$layout$shapes[[1]]
  expect_equal(c(zone$x0, zone$x1, zone$y0, zone$y1), c(20, 25, 40, 60))
  # 22 + hour / 4 is at most 25 up to hour 12: 13 of the 24 hours of each day
  title <- built$layout$title
  if (is.list(title)) title <- title$text
  expect_match(title, "54% of 72 hours", fixed = TRUE)
  expect_no_error(plotly::plotly_build(plot_comfort(temperature, humidity, mode = "dark")))
})
