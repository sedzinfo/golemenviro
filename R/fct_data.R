##########################################################################################
#
##########################################################################################
#' Metrics that the Pimoroni Enviro and Enviro+ export to Prometheus
#'
#' @noRd
metrics <- c(
  "temperature", "humidity", "pressure", "lux", "proximity",
  "NH3", "reducing", "oxidising", "PM1", "PM25", "PM10"
)

#' Column names of the metrics in the data from get_data()
#'
#' @noRd
metric_names <- c(
  date = "Date", timestamp = "Timestamp", temperature = "Temperature",
  humidity = "Humidity", pressure = "Pressure", lux = "Lux", proximity = "Proximity",
  reducing = "Reducing", oxidising = "Oxidising", PM25 = "PM2.5"
)
##########################################################################################
#
##########################################################################################
#' Query one metric from Prometheus
#'
#' @param urlq Prometheus query_range url.
#' @param metric Name of the metric, one of `metrics`.
#' @param start_time,end_time Start and end time, in UTC, in this format:
#'   "2025-01-31T11:48:08Z".
#' @param step Time between two readings, such as "10m".
#' @param average `TRUE` for the average of the readings over each step,
#'   instead of the single reading at each point in time.
#'
#' @return The `values` of the result: one matrix of times and values per
#'   series of the metric, or `NULL` when the answer cannot be read. An error
#'   when the server cannot be reached, takes longer than 15 seconds or
#'   answers with an error.
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' golemenviro:::query_prometheus(
#'   "http://pip1.crabdance.com:1507/api/v1/query_range", "temperature",
#'   format(Sys.time() - 3600, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
#'   format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
#'   "1m"
#' )
#' }
query_prometheus <- function(urlq, metric, start_time, end_time, step, average = FALSE) {
  query <- if (average) paste0("avg_over_time(", metric, "[", step, "])") else metric
  response <- httr::GET(
    urlq,
    query = list(query = query, start = start_time, end = end_time, step = step),
    httr::timeout(15)
  )
  httr::stop_for_status(response)
  result <- tryCatch(
    jsonlite::fromJSON(httr::content(response, as = "text", encoding = "UTF-8"), flatten = TRUE, simplifyDataFrame = TRUE),
    error = function(e) NULL
  )
  result$data$result$values
}
##########################################################################################
#
##########################################################################################
#' @title Get Data from Prometheus
#' @description Downloads the readings of all the sensors of a Pimoroni Enviro
#'   or Enviro+ from Prometheus, at about 1000 points in time between
#'   `start_time` and `end_time`. When these are an hour or more apart (a
#'   window of about 6 weeks or more), each point is the average of the
#'   readings since the previous one, so that the day and night cycle does not
#'   show up as noise; otherwise it is the reading at that time.
#' @param start_time start time, in UTC, in this format: "2025-01-31T11:48:08Z"
#' @param end_time end time, in UTC, in this format: "2025-02-07T11:48:33Z"
#' @param urlq Prometheus url
#' @return A data frame with the Date and the Timestamp of the readings and one
#'   column per sensor, or `NULL`, with a message, when the server cannot be
#'   reached or sends no data. Sensors whose readings never change are left
#'   out, as the device does not have them.
#' @importFrom jsonlite fromJSON
#' @importFrom httr GET content
#' @keywords prometheus query
#' @export
#' @examples
#' prometheus_url <- c(
#'   "http://pip1.crabdance.com:1507/api/v1/query_range",
#'   "http://pip1.crabdance.com:1505/api/v1/query_range"
#' )
#' start_time <- format(Sys.time() - 60 * 60 * 24 * 7, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
#' end_time <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
#' filtered_df <- get_data(start_time = start_time, end_time = end_time, urlq = prometheus_url[2])
#' head(filtered_df)
#' filtered_df <- get_data(start_time = start_time, end_time = end_time, urlq = prometheus_url[1])
#' head(filtered_df)
get_data <- function(start_time = format(Sys.time() - 60 * 60 * 24 * 7, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
                     end_time = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
                     urlq) {
  # 1000 points in time, in whole seconds: with the time of day, as a window can be shorter than a day
  window <- difftime(as.POSIXct(end_time, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
                     as.POSIXct(start_time, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), units = "secs")
  step_seconds <- max(1, round(as.numeric(window) / 999))
  time_step <- paste0(step_seconds, "s")
  xtsdf <- list()
  for (qm in metrics) {
    values <- tryCatch(
      query_prometheus(urlq, qm, start_time, end_time, time_step, average = step_seconds >= 3600),
      error = function(e) e
    )
    # a server that is offline fails on the first metric: stop there instead of waiting for each one
    if (inherits(values, "error")) {
      message("Could not get data from ", urlq, ": ", conditionMessage(values))
      return(NULL)
    }
    if (length(values) == 0) next
    # a metric can come in several series, for example after a restart: keep them all
    series <- lapply(values, function(v) data.frame(timestamp = as.numeric(v[, 1]), value = as.numeric(v[, 2])))
    time_series_data <- do.call(rbind, series)
    if (length(series) > 1) {
      time_series_data <- stats::aggregate(time_series_data["value"], by = time_series_data["timestamp"], FUN = mean)
    }
    time_series_data <- data.frame(
      date = as.POSIXct(time_series_data$timestamp),
      timestamp = time_series_data$timestamp,
      value = time_series_data$value
    )
    names(time_series_data) <- c("date", "timestamp", qm)
    xtsdf[[qm]] <- time_series_data
  }
  if (length(xtsdf) == 0) {
    message("No data from ", urlq)
    return(NULL)
  }
  filtered_df <- dfr <- Reduce(function(x, y) merge(x, y, by = c("date", "timestamp"), all = TRUE), xtsdf)
  cn <- data.frame(names = names(dfr), sd = sapply(dfr, stats::sd, na.rm = TRUE))
  filtered_df[, cn[cn$sd %in% 0, ]$names] <- NULL
  renamed <- names(filtered_df) %in% names(metric_names)
  names(filtered_df)[renamed] <- metric_names[names(filtered_df)[renamed]]
  return(filtered_df)
}
##########################################################################################
#
##########################################################################################
#' @title The name of a sensor in the app
#' @description The column name of its metric in the data from `get_data()`,
#' such as "PM2.5" for PM25, and the metric itself when it has none.
#' @param metric Names of metrics, from `metrics`.
#' @return A character vector as long as `metric`.
#' @noRd
sensor_label <- function(metric) {
  unname(ifelse(metric %in% names(metric_names), metric_names[metric], metric))
}
##########################################################################################
#
##########################################################################################
#' @title Get the hourly averages of one sensor
#' @description Asks Prometheus for the average of each clock hour of the last
#' `days` days, for the Daily Pattern tab. The average Prometheus gives at a
#' time covers the hour before it, so it is filed under the hour that starts
#' one hour earlier, in the time zone of the app.
#' @param urlq Prometheus query_range url.
#' @param metric Name of the metric, one of `metrics`.
#' @param days Number of days, up to the start of the current hour.
#' @param end_time The time to count back from, by default now.
#' @return A data frame with one row per hour: `date` (a Date), `hour` (0 to
#'   23) and `value`. It has no rows when the server has no readings of the
#'   metric in that time, and is `NULL`, with a message, when the server
#'   cannot be reached.
#' @keywords internal
#' @examples
#' \dontrun{
#' url <- "http://pip1.crabdance.com:1507/api/v1/query_range"
#' golemenviro:::get_hourly(url, "temperature", days = 7)
#' }
get_hourly <- function(urlq, metric, days = 30, end_time = Sys.time()) {
  end <- as.POSIXct(trunc(end_time, "hours"))
  start <- end - days * 24 * 60 * 60
  values <- tryCatch(
    query_prometheus(
      urlq, metric,
      format(start, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
      format(end, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
      "3600s",
      average = TRUE
    ),
    error = function(e) e
  )
  if (inherits(values, "error")) {
    message("Could not get data from ", urlq, ": ", conditionMessage(values))
    return(NULL)
  }
  if (length(values) == 0) {
    return(data.frame(date = as.Date(character()), hour = integer(), value = numeric()))
  }
  readings <- do.call(rbind, lapply(values, function(v) {
    data.frame(timestamp = as.numeric(v[, 1]), value = as.numeric(v[, 2]))
  }))
  readings$value[is.nan(readings$value)] <- NA
  hour_start <- as.POSIXct(readings$timestamp - 60 * 60, origin = "1970-01-01")
  readings$date <- as.Date(format(hour_start, "%Y-%m-%d"))
  readings$hour <- as.integer(format(hour_start, "%H"))
  # several series of the metric (after a restart), and the hour that repeats when the clocks go back
  hourly <- stats::aggregate(readings["value"], by = readings[c("date", "hour")], FUN = mean, na.rm = TRUE)
  hourly$value[is.nan(hourly$value)] <- NA
  hourly <- hourly[order(hourly$date, hourly$hour), c("date", "hour", "value")]
  rownames(hourly) <- NULL
  hourly
}
##########################################################################################
#
##########################################################################################
#' @title Get the daily averages of one sensor
#' @description The average of the hourly averages of each whole day, midnight
#' to midnight in the time zone of the app, of the `days` days before today,
#' for the Air Quality tab. Today, still running, is left out, and so is a day
#' with readings in fewer than 18 of its hours (75%), as in the usual rules for
#' daily averages of air quality.
#' @inheritParams get_hourly
#' @param end_time A time on the day after the last day, by default now.
#' @return A data frame with one row per day: `date` (a Date), `value` (the
#'   average) and `hours` (how many hours had readings). It has no rows when
#'   no day has enough readings, and is `NULL`, with a message, when the
#'   server cannot be reached.
#' @keywords internal
#' @examples
#' \dontrun{
#' url <- "http://pip1.crabdance.com:1507/api/v1/query_range"
#' golemenviro:::get_daily(url, "PM25", days = 30)
#' }
get_daily <- function(urlq, metric, days = 30, end_time = Sys.time()) {
  hourly <- get_hourly(urlq, metric, days, end_time = as.POSIXct(trunc(end_time, "days")))
  if (is.null(hourly)) {
    return(NULL)
  }
  hourly <- hourly[!is.na(hourly$value), ]
  daily <- data.frame(date = as.Date(character()), value = numeric(), hours = integer())
  if (nrow(hourly) > 0) {
    daily <- stats::aggregate(hourly["value"], by = hourly["date"], FUN = mean)
    daily$hours <- as.integer(table(hourly$date)[as.character(daily$date)])
  }
  daily <- daily[daily$hours >= 18, ]
  rownames(daily) <- NULL
  daily
}
