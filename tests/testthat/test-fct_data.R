test_that("get_data() combines the sensors, joins a split series and drops the constant ones", {
  local_mocked_bindings(query_prometheus = answer_from(answers))
  data <- get_data("2023-11-14T22:13:20Z", "2023-11-14T23:00:00Z", urlq = "http://x")
  expect_equal(data, readings, ignore_attr = TRUE)
})

test_that("get_data() asks for about 1000 readings, also in a window shorter than a day", {
  steps <- character()
  local_mocked_bindings(query_prometheus = function(urlq, metric, start_time, end_time, step, ...) {
    steps <<- c(steps, step)
    answers[[metric]]
  })
  get_data("2023-11-14T00:00:00Z", "2023-11-14T06:00:00Z", urlq = "http://x")
  get_data("2023-11-07T00:00:00Z", "2023-11-14T00:00:00Z", urlq = "http://x")
  expect_equal(unique(steps), c("22s", "605s"))
})

test_that("get_data() averages the readings over each step from steps of an hour", {
  averaged <- logical()
  local_mocked_bindings(query_prometheus = function(urlq, metric, start_time, end_time, step, average = FALSE) {
    averaged <<- c(averaged, average)
    answers[[metric]]
  })
  get_data("2023-08-14T00:00:00Z", "2023-11-14T00:00:00Z", urlq = "http://x") # 92 days, 2.2 hours apart
  expect_true(all(averaged))
  averaged <- logical()
  get_data("2023-10-14T00:00:00Z", "2023-11-14T00:00:00Z", urlq = "http://x") # 31 days, 45 minutes apart
  expect_false(any(averaged))
})

test_that("get_data() averages series of the same metric at the same time", {
  local_mocked_bindings(query_prometheus = answer_from(list(
    temperature = c(series(c(20, 21, 22, 23, 24)), series(c(22, 23, 24, 25, 26))),
    humidity = series(c(50, 51, 52, 53, 54))
  )))
  data <- get_data(urlq = "http://x")
  expect_equal(data$Temperature, c(21, 22, 23, 24, 25))
})

test_that("get_data() returns NULL with a message when the server cannot be reached", {
  local_mocked_bindings(query_prometheus = function(...) stop("Could not connect to server"))
  expect_message(data <- get_data(urlq = "http://x"), "Could not get data from http://x: Could not connect")
  expect_null(data)
})

test_that("get_data() stops at the first failed request instead of trying every metric", {
  requests <- 0
  local_mocked_bindings(query_prometheus = function(...) {
    requests <<- requests + 1
    stop("Timeout was reached")
  })
  expect_message(get_data(urlq = "http://x"))
  expect_equal(requests, 1)
})

test_that("get_data() returns NULL with a message when the server has no data", {
  local_mocked_bindings(query_prometheus = answer_from(list()))
  expect_message(data <- get_data(urlq = "http://x"), "No data from http://x")
  expect_null(data)
})

test_that("get_hourly() asks for hourly averages and files each under the hour it covers", {
  asked <- NULL
  local_mocked_bindings(query_prometheus = function(urlq, metric, start_time, end_time, step, average = FALSE) {
    asked <<- list(step = step, average = average, end_time = end_time)
    series(c(20, 22), times = timestamps[1] + 3600 * 1:2)
  })
  hourly <- get_hourly("http://x", "temperature", days = 1, end_time = as.POSIXct(timestamps[1] + 3 * 3600 + 120, origin = "1970-01-01"))
  expect_equal(asked$step, "3600s")
  expect_true(asked$average)
  # counted back from the start of the hour
  expect_equal(asked$end_time, format(as.POSIXct(trunc(as.POSIXct(timestamps[1] + 3 * 3600, origin = "1970-01-01"), "hours")), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"))
  first_hour <- as.POSIXct(timestamps[1], origin = "1970-01-01")
  expect_equal(hourly$value, c(20, 22))
  expect_equal(hourly$hour, as.integer(format(first_hour + 3600 * 0:1, "%H")))
  expect_equal(hourly$date, as.Date(format(first_hour + 3600 * 0:1, "%Y-%m-%d")))
})

test_that("get_hourly() averages series of the same hour, and keeps hours without readings empty", {
  local_mocked_bindings(query_prometheus = answer_from(list(
    temperature = c(series(c(20, NaN), timestamps[1:2]), series(c(22, NaN), timestamps[1:2]))
  )))
  hourly <- get_hourly("http://x", "temperature", days = 1)
  expect_equal(hourly$value[1], 21)
  expect_true(is.na(hourly$value[2]))
})

test_that("get_hourly() returns no rows without readings, and NULL with a message without a server", {
  local_mocked_bindings(query_prometheus = function(...) NULL)
  expect_equal(nrow(get_hourly("http://x", "NH3")), 0)
  local_mocked_bindings(query_prometheus = function(...) stop("Timeout was reached"))
  expect_message(expect_null(get_hourly("http://x", "NH3")), "Could not get data from http://x")
})

test_that("get_daily() averages whole days before today, and leaves out days with too few hours", {
  ends <- NULL
  local_mocked_bindings(get_hourly = function(urlq, metric, days, end_time) {
    ends <<- end_time
    data.frame(
      date = as.Date("2023-11-01") + rep(0:2, c(24, 17, 24)),
      hour = c(0:23, 0:16, 0:23),
      value = c(rep(10, 24), rep(50, 17), rep(20, 24))
    )
  })
  daily <- get_daily("http://x", "PM25", days = 3, end_time = as.POSIXct("2023-11-04 15:30"))
  expect_equal(format(ends, "%Y-%m-%d %H:%M"), "2023-11-04 00:00")
  expect_equal(daily$date, as.Date(c("2023-11-01", "2023-11-03")))
  expect_equal(daily$value, c(10, 20))
  expect_equal(daily$hours, c(24L, 24L))
})

test_that("get_daily() passes on that the server cannot be reached", {
  local_mocked_bindings(get_hourly = function(...) NULL)
  expect_null(get_daily("http://x", "PM25"))
})
