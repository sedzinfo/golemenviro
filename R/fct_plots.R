##########################################################################################
#
##########################################################################################
#' Greek mu and sigma, degrees Celsius, and micrograms per cubic metre
#'
#' Written as code points, as the R code of a package has to stay ASCII.
#'
#' @noRd
symbol_mean <- intToUtf8(0x03bc)
symbol_sd <- intToUtf8(0x03c3)
degrees_celsius <- paste0(intToUtf8(0x00b0), "C")
micrograms_m3 <- paste0(intToUtf8(0x00b5), "g/m", intToUtf8(0x00b3))
##########################################################################################
#
##########################################################################################
#' @title Plot Time Series
#' @description Plots the readings of one sensor, with their moving average,
#'   their mean, and a summary of the last reading, mean, minimum, maximum,
#'   standard deviation, range and dates on the right.
#' @param data data frame from get_data()
#' @param variable one of "Temperature" "Humidity" "Pressure" "Lux" "Proximity" "NH3" "Reducing" "Oxidising" "PM1" "PM2.5" "PM10"
#' @param scale title of the y axis
#' @param k integer width of the rolling window. Must be odd for rollmedian
#' @return A plotly object.
#' @import plotly
#' @importFrom zoo rollmean
#' @keywords plot timeseries
#' @export
#' @examples
#' prometheus_url <- c(
#'   "http://pip1.crabdance.com:1507/api/v1/query_range",
#'   "http://pip1.crabdance.com:1505/api/v1/query_range"
#' )
#' filtered_df <- get_data(urlq = prometheus_url[1])
#' plot_time_series(data = filtered_df, variable = "Temperature")
#' plot_time_series(data = filtered_df, variable = "Humidity")
#' plot_time_series(data = filtered_df, variable = "Pressure")
#' plot_time_series(data = filtered_df, variable = "PM2.5")
plot_time_series <- function(data, variable = "Temperature", scale = "", k = 30) {
  smoothed <- zoo::rollmean(as.numeric(data[, variable]), k = k, align = "center", fill = NA)
  current_value <- round(as.numeric(data[nrow(data), variable]), 2)
  mean_value <- round(mean(as.numeric(data[, variable]), na.rm = TRUE), 2)
  min_value <- round(min(as.numeric(data[, variable]), na.rm = TRUE), 2)
  max_value <- round(max(as.numeric(data[, variable]), na.rm = TRUE), 2)
  sd_value <- round(stats::sd(as.numeric(data[, variable]), na.rm = TRUE), 2)
  range_value <- round(max_value - min_value, 2)
  plot_ts <- plot_ly(
    data = data,
    x = data[, "Date"],
    y = data[, variable],
    text = paste0("\nDate=", data[, "Date"], "\n", variable, "=", round(data[, variable], 2), "\n"),
    type = "scatter",
    mode = "lines",
    name = variable
  ) %>%
    add_lines(
      data = data,
      x = data[, "Date"],
      y = smoothed,
      text = paste0("\nDate=", data[, "Date"], "\n", variable, "=", round(smoothed, 2), "\n"),
      type = "scatter",
      mode = "lines",
      name = "Smoothing"
    ) %>%
    add_segments(
      x = min(data[, "Date"]),
      xend = max(data[, "Date"]),
      y = mean_value,
      yend = mean_value,
      name = "Mean"
    ) %>%
    add_annotations(
      text = paste(
        "\n\n",
        "last:", current_value, "\n\n",
        paste0(symbol_mean, ":"), mean_value, "\n",
        "min:", min_value, "\n",
        "max:", max_value, "\n",
        paste0(symbol_sd, ":"), sd_value, "\n",
        "range:", range_value, "\n\n",
        "Start:", min(format(data[, "Date"], "%Y-%m-%d")), "\n",
        "Stop:", max(format(data[, "Date"], "%Y-%m-%d")), "\n"
      ),
      xref = "paper",
      yref = "paper",
      # a fixed 10 px from the plot, as a share of its width runs off the edge of a wide chart
      x = 1,
      xshift = 10,
      y = 0.1,
      xanchor = "left",
      yanchor = "bottom",
      showarrow = FALSE,
      font = list(size = 12),
      align = "left"
    ) %>%
    layout(
      autosize = TRUE,
      # room on the right for the summary
      margin = list(l = 80, r = 140, b = 80, t = 50, pad = 50),
      # at the bottom of the chart, below the dates, as on the right it runs into the summary in narrow charts
      legend = list(orientation = "h", x = 0, xanchor = "left", yref = "container", y = 0, yanchor = "bottom"),
      title = variable,
      xaxis = list(title = ""),
      yaxis = list(title = scale),
      template = "plotly_dark"
    )
  return(plot_ts)
}
##########################################################################################
#
##########################################################################################
#' @title Plot Gauge
#' @description Plots the last reading of one sensor as a gauge, with the
#'   ideal range in green and a short note on what the gas and particle
#'   sensors measure. The ideal ranges of PM2.5 and PM10 are the 24-hour
#'   guidelines of the WHO (2021); PM1, which has none, gets that of PM2.5. The
#'   gas and proximity sensors have no fixed range, so their gauge is
#'   scaled to all the readings of `data`: it spans the lowest to the highest
#'   reading, widened by one standard deviation, the green band is the mean plus
#'   or minus one standard deviation, and the delta is the difference from the
#'   mean.
#' @param data data frame from get_data(); the gauge shows its last reading
#' @param variable one of "Temperature" "Humidity" "Pressure" "Lux" "Proximity" "NH3" "Reducing" "Oxidising" "PM1" "PM2.5" "PM10"
#' @return A plotly object.
#' @import plotly
#' @keywords plot gauge
#' @export
#' @examples
#' prometheus_url <- c(
#'   "http://pip1.crabdance.com:1507/api/v1/query_range",
#'   "http://pip1.crabdance.com:1505/api/v1/query_range"
#' )
#' filtered_df <- get_data(urlq = prometheus_url[1])
#' plot_gauge(data = filtered_df, variable = "Temperature")
#' plot_gauge(data = filtered_df, variable = "Humidity")
#' plot_gauge(data = filtered_df, variable = "PM2.5")
plot_gauge <- function(data, variable = "Temperature") {
  help_pm1 <- "Ultra fine particles"
  help_pm25 <- "Combustion particles,Organic compounds,Metals"
  help_pm10 <- "Dust,Pollen,Mould spores"
  help_NH3 <- "Mostly Ammonia,\n Hydrogen,Ethanol,Propane,Iso-butane"
  help_reducing <- "Mostly Carbon Monoxide,\n H2S,Ammonia,Ethanol,Hydrogen,Methane,Propane,Iso-butane"
  help_oxidising <- "Mostly Nitrogen Dioxide,\n NO,Hydrogen"
  names <- c(
    "Temperature", "Humidity", "Pressure", "Lux", "Proximity",
    "NH3", "Reducing", "Oxidising", "PM1", "PM2.5", "PM10"
  )
  # the units after the number: a space before those that are words, as in "1,013 hPa"
  ugm3 <- paste0(" ", micrograms_m3)
  scale <- c(degrees_celsius, "%", " hPa", " lux", NA, " Ohms", " Ohms", " Ohms", ugm3, ugm3, ugm3)
  # NA: scaled to the readings (proximity and the gases); PM2.5 and PM10: the 24-hour WHO guidelines
  range_ideal_min <- c(20, 40, 1010, 1000, NA, NA, NA, NA, 0, 0, 0)
  range_ideal_max <- c(25, 60, 1015, 1500, NA, NA, NA, NA, 15, 15, 45)
  point_ideal <- c(24, 50, 1013, 1200, NA, NA, NA, NA, 0, 0, 0)
  range_min <- c(-50, 0, 900, 0, NA, NA, NA, NA, 0, 0, 0)
  range_max <- c(50, 100, 1100, 10000, NA, NA, NA, NA, 400, 400, 400)
  help <- c(rep("", 5), help_NH3, help_reducing, help_oxidising, help_pm1, help_pm25, help_pm10)
  df_reference <- data.frame(
    query = metrics, names = names, scale, range_min, range_max,
    range_ideal_min, range_ideal_max, point_ideal, help = help
  )
  dflast <- data[data$Timestamp %in% max(data$Timestamp), ]
  last_value <- dflast[, variable]
  # the sensors without a fixed range are scaled to all the readings, not only the last
  value_mean <- mean(data[, variable], na.rm = TRUE)
  value_sd <- stats::sd(data[, variable], na.rm = TRUE)
  value_max <- max(data[, variable], na.rm = TRUE)
  value_min <- min(data[, variable], na.rm = TRUE)
  reference <- df_reference[df_reference$names %in% variable, ]

  range <- c(reference$range_min, reference$range_max)
  range_ideal <- c(reference$range_ideal_min, reference$range_ideal_max)
  point_ideal <- reference$point_ideal

  if (anyNA(range)) {
    range <- c(value_min - value_sd, value_max + value_sd)
  }
  if (anyNA(range_ideal)) {
    range_ideal <- c(value_mean - value_sd, value_mean + value_sd)
  }
  if (is.na(point_ideal)) {
    point_ideal <- value_mean
  }

  plot_g <- plot_ly(
    type = "indicator",
    mode = "gauge+number+delta",
    value = last_value,
    number = list(suffix = reference$scale),
    title = list(text = variable, font = list(size = 20)),
    delta = list(
      reference = point_ideal,
      increasing = list(color = "#404444"),
      decreasing = list(color = "#404444")
    ),
    gauge = list(
      axis = list(range = range, tickwidth = 1, tickcolor = "darkblue"),
      bar = list(color = "red"),
      bgcolor = "white",
      borderwidth = 2,
      bordercolor = "gray",
      steps = list(list(range = range_ideal, color = "green")),
      threshold = list(
        line = list(color = "darkblue", width = 1),
        thickness = 5,
        value = point_ideal
      )
    )
  ) %>%
    layout(
      margin = list(l = 80, r = 80, b = 80, t = 50, pad = 50),
      paper_bgcolor = "white",
      font = list(color = "darkblue")
    ) %>%
    add_annotations(
      text = reference$help,
      x = .5,
      y = -.1,
      showarrow = FALSE
    )
  return(plot_g)
}
##########################################################################################
#
##########################################################################################
#' @title Units of the metrics
#' @description By metric name, for the color bars, axes and hover labels of the
#' Daily Pattern tab; proximity has none.
#' @noRd
metric_units <- c(
  temperature = degrees_celsius, humidity = "%", pressure = "hPa", lux = "lux", proximity = "",
  NH3 = "Ohms", reducing = "Ohms", oxidising = "Ohms",
  PM1 = micrograms_m3, PM25 = micrograms_m3, PM10 = micrograms_m3
)
##########################################################################################
#
##########################################################################################
#' @title Steps of one blue, from light to dark
#' @description The color scale of the daily pattern. In dark mode it runs the
#' other way, so that low values fade into the dark page and high values stand
#' out, as they do on a light page.
#' @noRd
blue_steps <- c("#cde2fb", "#86b6ef", "#3987e5", "#1c5cab", "#0d366b")
##########################################################################################
#
##########################################################################################
#' @title The time zone of the app
#' @description The one [pimoroni()] sets while the app runs, for the axis
#' titles of the hours.
#' @return The name of the time zone, such as "Europe/Bucharest".
#' @noRd
app_time_zone <- function() {
  Sys.timezone()
}
##########################################################################################
#
##########################################################################################
#' @title Heatmap of the hourly averages of one sensor
#' @description A column per day and a row per hour of the day, from midnight at
#' the top, each colored by the average of that hour, so that what happens at
#' the same time every day shows as a horizontal band. The colors stop at the
#' 2nd and 98th percentiles, so that a few spikes do not wash out the rest;
#' the hover label has the exact value.
#' @param hourly Data frame from [get_hourly()].
#' @param variable Name of the sensor, for the title and the hover labels.
#' @param unit Unit of the readings, `""` for none.
#' @param mode `"light"` or `"dark"`, the mode of the app.
#' @return A plotly object.
#' @keywords internal
#' @examples
#' hourly <- expand.grid(hour = 0:23, date = as.Date("2026-10-01") + 0:13)
#' hourly$value <- 21 + 2 * sin((hourly$hour - 9) / 24 * 2 * pi)
#' golemenviro:::plot_daily_pattern(hourly, "Temperature", "C")
plot_daily_pattern <- function(hourly, variable, unit = "", mode = "light") {
  dates <- seq(min(hourly$date), max(hourly$date), by = "day")
  z <- matrix(NA_real_, nrow = 24, ncol = length(dates))
  z[cbind(hourly$hour + 1, match(hourly$date, dates))] <- hourly$value
  hours <- sprintf("%02d:00", 0:23)
  value_text <- ifelse(
    is.na(z),
    "no readings",
    paste0(formatC(z, format = "f", digits = 1, big.mark = ","), if (nzchar(unit)) " ", unit)
  )
  hover <- matrix(paste0(
    format(rep(dates, each = 24), "%a %d %b %Y"), ", ",
    rep(hours, length(dates)), "-", rep(c(hours[-1], hours[1]), length(dates)),
    "<br>", variable, ": ", value_text
  ), nrow = 24)
  limits <- stats::quantile(hourly$value, c(0.02, 0.98), na.rm = TRUE, names = FALSE)
  steps <- if (identical(mode, "dark")) rev(blue_steps) else blue_steps
  plot_ly(
    x = dates,
    y = 0:23,
    z = z,
    type = "heatmap",
    zmin = limits[1],
    zmax = limits[2],
    colorscale = lapply(seq_along(steps), function(i) list((i - 1) / (length(steps) - 1), steps[i])),
    colorbar = list(title = list(text = unit), thickness = 12),
    text = hover,
    hovertemplate = "%{text}<extra></extra>",
    # a thin gap of the page between the cells, left out when the days are too narrow for it
    xgap = if (length(dates) <= 120) 1 else 0,
    ygap = 1
  ) %>%
    layout(
      title = paste(variable, "by hour of the day"),
      xaxis = list(title = "", showgrid = FALSE),
      yaxis = list(
        title = paste0("Hour (", app_time_zone(), ")"),
        autorange = "reversed",
        tickvals = seq(0, 21, 3),
        ticktext = hours[seq(1, 22, 3)],
        showgrid = FALSE,
        zeroline = FALSE
      ),
      margin = list(l = 80, r = 40, b = 50, t = 50)
    )
}
##########################################################################################
#
##########################################################################################
#' @title A typical day of one sensor
#' @description For each hour of the day, the median of the hourly averages
#' over all the days (the line), and the middle half of the days, between the
#' 25th and 75th percentiles (the band): a narrow band means that hour is much
#' the same every day.
#' @inheritParams plot_daily_pattern
#' @return A plotly object.
#' @keywords internal
#' @examples
#' hourly <- expand.grid(hour = 0:23, date = as.Date("2026-10-01") + 0:13)
#' hourly$value <- 21 + 2 * sin((hourly$hour - 9) / 24 * 2 * pi) + rnorm(nrow(hourly), sd = 0.5)
#' golemenviro:::plot_average_day(hourly, "Temperature", "C")
plot_average_day <- function(hourly, variable, unit = "", mode = "light") {
  by_hour <- split(hourly$value, factor(hourly$hour, levels = 0:23))
  quartiles <- t(vapply(by_hour, function(x) {
    if (all(is.na(x))) rep(NA_real_, 3) else stats::quantile(x, c(0.25, 0.5, 0.75), na.rm = TRUE, names = FALSE)
  }, numeric(3)))
  hours <- 0:23
  labels <- sprintf("%02d:00", hours)
  in_unit <- function(x) paste0(formatC(x, format = "f", digits = 1, big.mark = ","), if (nzchar(unit)) " ", unit)
  line <- if (identical(mode, "dark")) "#3987e5" else "#2a78d6"
  band <- if (identical(mode, "dark")) "rgba(57,135,229,0.3)" else "rgba(42,120,214,0.2)"
  plot_ly(x = hours) %>%
    add_lines(y = quartiles[, 1], line = list(width = 0), hoverinfo = "skip", showlegend = FALSE) %>%
    add_lines(
      y = quartiles[, 3],
      fill = "tonexty",
      fillcolor = band,
      line = list(width = 0),
      hoverinfo = "skip",
      name = "Middle half of the days"
    ) %>%
    add_lines(
      y = quartiles[, 2],
      line = list(width = 2, color = line),
      name = "Median",
      text = paste0(
        labels, "-", c(labels[-1], labels[1]),
        "<br>median: ", in_unit(quartiles[, 2]),
        "<br>middle half: ", in_unit(quartiles[, 1]), " to ", in_unit(quartiles[, 3])
      ),
      hovertemplate = "%{text}<extra></extra>"
    ) %>%
    layout(
      title = paste("A typical day of", variable),
      xaxis = list(title = paste0("Hour (", app_time_zone(), ")"), tickvals = seq(0, 21, 3), ticktext = labels[seq(1, 22, 3)]),
      yaxis = list(title = unit),
      legend = list(orientation = "h", x = 0, xanchor = "left", yref = "container", y = 0, yanchor = "bottom"),
      margin = list(l = 80, r = 40, b = 80, t = 50)
    )
}
##########################################################################################
#
##########################################################################################
#' @title The guidelines of the World Health Organization for particles
#' @description The air quality guidelines of 2021, in micrograms per cubic metre:
#' for the average of a day, which should not be exceeded on more than 3 to 4
#' days a year (the 99th percentile), and for the average of a year. PM1 has
#' none.
#' @noRd
who_guidelines <- data.frame(
  metric = c("PM25", "PM10"),
  day = c(15, 45),
  year = c(5, 15)
)
##########################################################################################
#
##########################################################################################
#' @title Bars of the daily averages of a particle sensor
#' @description One bar per day, with the guideline of the World Health
#' Organization for the average of a day as a dashed line, so the days above it
#' stand out. The axis starts at 0 and always reaches above the guideline.
#' @param daily Data frame from [get_daily()].
#' @param variable Name of the sensor, for the title and the hover labels.
#' @param guideline The guideline for the average of a day.
#' @param mode `"light"` or `"dark"`, the mode of the app.
#' @return A plotly object.
#' @keywords internal
#' @examples
#' daily <- data.frame(date = as.Date("2026-10-01") + 0:29, value = 8 + 10 * abs(sin(1:30)), hours = 24)
#' golemenviro:::plot_daily_means(daily, "PM2.5", 15)
plot_daily_means <- function(daily, variable, guideline, mode = "light") {
  dark <- identical(mode, "dark")
  unit <- micrograms_m3
  hover <- paste0(
    format(daily$date, "%a %d %b %Y"), "<br>", variable, ": ",
    formatC(daily$value, format = "f", digits = 1), " ", unit,
    ifelse(daily$hours < 24, paste0(" (", daily$hours, " hours with readings)"), "")
  )
  plot_ly(
    x = daily$date,
    y = daily$value,
    type = "bar",
    marker = list(color = if (dark) "#3987e5" else "#2a78d6"),
    text = hover,
    textposition = "none",
    hovertemplate = "%{text}<extra></extra>"
  ) %>%
    layout(
      title = paste(variable, "average of each day"),
      xaxis = list(title = ""),
      yaxis = list(title = unit, range = c(0, max(guideline * 1.25, daily$value * 1.05, na.rm = TRUE))),
      bargap = 0.15,
      shapes = list(list(
        type = "line", xref = "paper", x0 = 0, x1 = 1, y0 = guideline, y1 = guideline,
        line = list(color = if (dark) "#c3c2b7" else "#52514e", width = 1.5, dash = "dash")
      )),
      # the label of the line to its right, outside the bars, which can reach above it
      annotations = list(list(
        text = paste0("WHO guideline<br>for a day: ", guideline, " ", unit),
        xref = "paper", x = 1, xanchor = "left", xshift = 8, y = guideline, yanchor = "middle",
        align = "left", showarrow = FALSE, font = list(size = 12)
      )),
      margin = list(l = 80, r = 140, b = 50, t = 50)
    )
}
