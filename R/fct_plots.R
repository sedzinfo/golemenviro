##########################################################################################
#
##########################################################################################
#' @title Greek mu and sigma, degrees Celsius, and micrograms per cubic metre
#' @description Written as code points, as the R code of a package has to stay ASCII.
#' @format Character strings.
#' @export
#' @examples
#' paste0("22 ", degrees_celsius, ", ", symbol_mean, " = 12 ", micrograms_m3)
symbol_mean <- intToUtf8(0x03bc)
#' @rdname symbol_mean
#' @export
symbol_sd <- intToUtf8(0x03c3)
#' @rdname symbol_mean
#' @export
degrees_celsius <- paste0(intToUtf8(0x00b0), "C")
#' @rdname symbol_mean
#' @export
micrograms_m3 <- paste0(intToUtf8(0x00b5), "g/m", intToUtf8(0x00b3))
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
#' @format A character vector of 5 hexadecimal colors.
#' @export
#' @examples
#' blue_steps
blue_steps <- c("#cde2fb", "#86b6ef", "#3987e5", "#1c5cab", "#0d366b")
##########################################################################################
#
##########################################################################################
#' @title Steps of one red, from light to dark
#' @description The red counterpart of [blue_steps], with the same lightness at
#' each step, for scales where higher means hotter or worse. Reverse it with
#' `rev(red_steps)` in dark mode, as [plot_daily_pattern()] does with blue.
#' @format A character vector of 5 hexadecimal colors.
#' @export
#' @examples
#' red_steps
#' # as a plotly color scale
#' lapply(seq_along(red_steps), function(i) list((i - 1) / 4, red_steps[i]))
red_steps <- c("#fbd3cf", "#f28d84", "#e0463b", "#a91f17", "#660d08")
##########################################################################################
#
##########################################################################################
#' @title The value colored white in the daily pattern of each metric
#' @description By metric name, the value that [plot_daily_pattern()] colors
#' white, with lower values in blue and higher in red: room temperature, the
#' middle of the comfortable range of humidity (40 to 60%), the standard
#' atmospheric pressure at sea level, and for particles the daily guideline of
#' the World Health Organization ([who_guidelines]). `NA` for the metrics with
#' no such value (light, proximity, the gas sensors, whose resistance is only
#' relative, and PM1, which has no guideline): these keep [blue_steps].
#' @format A named numeric vector, in the units of the readings.
#' @export
#' @examples
#' metric_mid
#' metric_mid[["temperature"]]
metric_mid <- c(
  temperature = 24, humidity = 50, pressure = 1013.25, lux = NA, proximity = NA,
  NH3 = NA, reducing = NA, oxidising = NA,
  PM1 = NA, PM25 = 15, PM10 = 45
)
##########################################################################################
#
##########################################################################################
#' @title The time zone of the app
#' @description The one [pimoroni()] sets while the app runs, for the axis
#' titles of the hours.
#' @return The name of the time zone, such as "Europe/Bucharest".
#' @export
#' @examples
#' app_time_zone()
app_time_zone <- function() {
  Sys.timezone()
}
##########################################################################################
#
##########################################################################################
#' @title The guidelines of the World Health Organization for particles
#' @description The air quality guidelines of 2021, in micrograms per cubic metre:
#' for the average of a day, which should not be exceeded on more than 3 to 4
#' days a year (the 99th percentile), and for the average of a year. PM1 has
#' none.
#' @format A data frame with the columns `metric` (`"PM25"`, `"PM10"`), `day`
#'   and `year`, in micrograms per cubic metre.
#' @export
#' @examples
#' who_guidelines
who_guidelines <- data.frame(
  metric = c("PM25", "PM10"),
  day = c(15, 45),
  year = c(5, 15)
)
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
  plot_ts <- plotly::plot_ly(
    data = data,
    x = data[, "Date"],
    y = data[, variable],
    text = paste0("\nDate=", data[, "Date"], "\n", variable, "=", round(data[, variable], 2), "\n"),
    type = "scatter",
    mode = "lines",
    name = variable
  ) |>
    plotly::add_lines(
      data = data,
      x = data[, "Date"],
      y = smoothed,
      text = paste0("\nDate=", data[, "Date"], "\n", variable, "=", round(smoothed, 2), "\n"),
      type = "scatter",
      mode = "lines",
      name = "Smoothing"
    ) |>
    plotly::add_segments(
      x = min(data[, "Date"]),
      xend = max(data[, "Date"]),
      y = mean_value,
      yend = mean_value,
      name = "Mean"
    ) |>
    plotly::add_annotations(
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
    ) |>
    plotly::layout(
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

  plot_g <- plotly::plot_ly(
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
  ) |>
    plotly::layout(
      margin = list(l = 80, r = 80, b = 80, t = 50, pad = 50),
      paper_bgcolor = "white",
      font = list(color = "darkblue")
    ) |>
    plotly::add_annotations(
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
#' @param mid A value to color white, with lower values in blue and higher values
#'   in red, such as room temperature; the color range is then made symmetric
#'   around it. `NULL` (the default) for one blue, from light to dark.
#' @return A plotly object.
#' @export
#' @examples
#' hourly <- expand.grid(hour = 0:23, date = as.Date("2026-10-01") + 0:13)
#' hourly$value <- 21 + 2 * sin((hourly$hour - 9) / 24 * 2 * pi)
#' plot_daily_pattern(hourly, "Temperature", "C")
#' plot_daily_pattern(hourly, "Temperature", "C", mid = 24)
#' url <- "http://pip1.crabdance.com:1507/api/v1/query_range"
#' plot_daily_pattern(get_hourly(url, "temperature", days = 30), "Temperature", "C", mid = 30)
#' plot_daily_pattern(get_hourly(url, "temperature", days = 360), "Temperature", "C", mid = 30)
plot_daily_pattern <- function(hourly, variable, unit = "", mode = "light", mid = NULL) {
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
  # limits <- stats::quantile(hourly$value, c(0.02, 0.98), na.rm = TRUE, names = FALSE)
  # steps <- if (identical(mode, "dark")) rev(blue_steps) else blue_steps
  limits <- stats::quantile(hourly$value, c(0.02, 0.98), na.rm = TRUE, names = FALSE)
  if (is.null(mid)) {
    steps <- if (identical(mode, "dark")) rev(blue_steps) else blue_steps
  } else {
    half <- max(abs(limits - mid))
    limits <- c(mid - half, mid + half)
    steps <- c("#2166AC", "#67A9CF", "#F7F7F7", "#EF8A62", "#B2182B") # ColorBrewer RdBu
  }
  
  plotly::plot_ly(
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
  ) |>
    plotly::layout(
      title = paste(variable, "by hour of the day"),
      xaxis = list(title = "", showgrid = FALSE, tickangle = -90, nticks = 12),
      yaxis = list(
        title = paste0("Hour (", app_time_zone(), ")"),
        autorange = "reversed",
        tickvals = seq(0, 23, 1),
        ticktext = hours[seq(1, 24, 1)],
        showgrid = FALSE,
        zeroline = FALSE
      ),
      margin = list(l = 80, r = 40, b = 90, t = 50)
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
#' @export
#' @examples
#' hourly <- expand.grid(hour = 0:23, date = as.Date("2026-10-01") + 0:13)
#' hourly$value <- 21 + 2 * sin((hourly$hour - 9) / 24 * 2 * pi) + rnorm(nrow(hourly), sd = 0.5)
#' plot_average_day(hourly, "Temperature", "C")
#' url <- "http://pip1.crabdance.com:1507/api/v1/query_range"
#' plot_average_day(get_hourly(url, "humidity", days = 30), "Humidity", "%")
#' plot_average_day(get_hourly(url, "humidity", days = 360), "Humidity", "%")
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
  plotly::plot_ly(x = hours) |>
    plotly::add_lines(y = quartiles[, 1], line = list(width = 0), hoverinfo = "skip", showlegend = FALSE) |>
    plotly::add_lines(
      y = quartiles[, 3],
      fill = "tonexty",
      fillcolor = band,
      line = list(width = 0),
      hoverinfo = "skip",
      name = "Middle half of the days"
    ) |>
    plotly::add_lines(
      y = quartiles[, 2],
      line = list(width = 2, color = line),
      name = "Median",
      text = paste0(
        labels, "-", c(labels[-1], labels[1]),
        "<br>median: ", in_unit(quartiles[, 2]),
        "<br>middle half: ", in_unit(quartiles[, 1]), " to ", in_unit(quartiles[, 3])
      ),
      hovertemplate = "%{text}<extra></extra>"
    ) |>
    plotly::layout(
      title = paste("A typical day of", variable),
      xaxis = list(title = paste0("Hour (", app_time_zone(), ")"), tickvals = seq(0, 23, 1), ticktext = labels[seq(1, 24, 1)]),
      yaxis = list(title = unit),
      legend = list(orientation = "h", x = 0, xanchor = "left", yref = "container", y = 0, yanchor = "bottom"),
      margin = list(l = 80, r = 40, b = 80, t = 50)
    )
}
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
#' @export
#' @examples
#' daily <- data.frame(date = as.Date("2026-10-01") + 0:29, value = 8 + 10 * abs(sin(1:30)), hours = 24)
#' plot_daily_means(daily, "PM2.5", 15)
#' url <- "http://pip1.crabdance.com:1507/api/v1/query_range"
#' plot_daily_means(get_daily(url, "PM25", days = 30), "PM2.5", 15)
plot_daily_means <- function(daily, variable, guideline, mode = "light") {
  dark <- identical(mode, "dark")
  unit <- micrograms_m3
  hover <- paste0(
    format(daily$date, "%a %d %b %Y"), "<br>", variable, ": ",
    formatC(daily$value, format = "f", digits = 1), " ", unit,
    ifelse(daily$hours < 24, paste0(" (", daily$hours, " hours with readings)"), "")
  )
  plotly::plot_ly(
    x = daily$date,
    y = daily$value,
    type = "bar",
    marker = list(color = if (dark) "#3987e5" else "#2a78d6"),
    text = hover,
    textposition = "none",
    hovertemplate = "%{text}<extra></extra>"
  ) |>
    plotly::layout(
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
##########################################################################################
#
##########################################################################################
#' @title Share of hours in and around the comfort zone
#' @description Pairs the hourly averages of temperature and humidity by hour
#' and counts how many hours fall inside the comfortable ranges, and how many
#' are too warm, too cool, too dry or too humid (an hour can be both too warm
#' and too dry).
#' @param temperature,humidity Data frames from [get_hourly()] of temperature
#'   and humidity.
#' @param temperature_range,humidity_range The comfortable ranges, the same as
#'   the green bands of the Current tab: 20 to 25 degrees Celsius and 40 to 60%.
#' @return A list: `hours`, the number of hours with both readings, and the
#'   percentages `comfortable`, `too_warm`, `too_cool`, `too_dry` and `too_humid`.
#' @export
#' @examples
#' hours <- expand.grid(hour = 0:23, date = as.Date("2026-10-01") + 0:6)
#' temperature <- transform(hours, value = 22 + 4 * sin((hour - 9) / 24 * 2 * pi))
#' humidity <- transform(hours, value = 45 - 8 * sin((hour - 9) / 24 * 2 * pi))
#' comfort_summary(temperature, humidity)
comfort_summary <- function(temperature, humidity, temperature_range = c(20, 25), humidity_range = c(40, 60)) {
  both <- comfort_pairs(temperature, humidity)
  share <- function(x) if (nrow(both)) 100 * mean(x) else NA_real_
  list(
    hours = nrow(both),
    comfortable = share(both$temperature >= temperature_range[1] & both$temperature <= temperature_range[2] &
      both$humidity >= humidity_range[1] & both$humidity <= humidity_range[2]),
    too_warm = share(both$temperature > temperature_range[2]),
    too_cool = share(both$temperature < temperature_range[1]),
    too_dry = share(both$humidity < humidity_range[1]),
    too_humid = share(both$humidity > humidity_range[2])
  )
}
##########################################################################################
#
##########################################################################################
#' @title Temperature and humidity of the same hours, side by side
#' @param temperature,humidity Data frames from [get_hourly()].
#' @return A data frame with the columns `date`, `hour`, `temperature` and
#'   `humidity`, only the hours with both readings.
#' @noRd
comfort_pairs <- function(temperature, humidity) {
  both <- merge(
    stats::setNames(temperature[c("date", "hour", "value")], c("date", "hour", "temperature")),
    stats::setNames(humidity[c("date", "hour", "value")], c("date", "hour", "humidity")),
    by = c("date", "hour")
  )
  both[stats::complete.cases(both), , drop = FALSE]
}
##########################################################################################
#
##########################################################################################
#' @title Comfort zone: temperature against humidity
#' @description A point for every hour, at its average temperature and
#' humidity, colored by the hour of the day (night blue, morning orange, midday
#' yellow, evening red), over a shaded box for the comfortable ranges. The
#' title says how many of the hours were inside the box, and the corners name
#' what lies that way: warm and dry, warm and humid, cool and dry, cool and humid.
#' @inheritParams comfort_summary
#' @param mode `"light"` or `"dark"`, the mode of the app.
#' @return A plotly object.
#' @export
#' @examples
#' hours <- expand.grid(hour = 0:23, date = as.Date("2026-10-01") + 0:6)
#' temperature <- transform(hours, value = 22 + 4 * sin((hour - 9) / 24 * 2 * pi))
#' humidity <- transform(hours, value = 45 - 8 * sin((hour - 9) / 24 * 2 * pi))
#' plot_comfort(temperature, humidity)
#' plot_comfort(temperature, humidity, mode = "dark")
plot_comfort <- function(temperature, humidity, mode = "light",
                         temperature_range = c(20, 25), humidity_range = c(40, 60)) {
  dark <- identical(mode, "dark")
  both <- comfort_pairs(temperature, humidity)
  summary <- comfort_summary(temperature, humidity, temperature_range, humidity_range)
  hours <- sprintf("%02d:00", 0:23)
  hover <- paste0(
    format(both$date, "%a %d %b %Y"), ", ", hours[both$hour + 1], "<br>",
    formatC(both$temperature, format = "f", digits = 1), " ", degrees_celsius, ", ",
    formatC(both$humidity, format = "f", digits = 0), "% humidity"
  )
  # the hours around the clock: night blue, morning orange, midday yellow, evening red, night
  # again; on a dark page the night blue is lighter, or the night points would vanish into it
  night <- if (dark) "#6f86e8" else "#1b2a6b"
  hour_colors <- list(
    list(0, night), list(0.25, "#e07b39"), list(0.5, "#f2c14e"), list(0.75, "#c2185b"), list(1, night)
  )
  # the axes reach past the comfort zone on every side, whatever the readings
  pad <- function(x, range) c(min(x, range[1] - 2, na.rm = TRUE) - 1, max(x, range[2] + 2, na.rm = TRUE) + 1)
  x_range <- pad(both$temperature, temperature_range)
  y_range <- pad(both$humidity, humidity_range)
  ink <- if (dark) "#c3c2b7" else "#52514e"
  zone <- if (dark) "#5fbf73" else "#2e8b47"
  corner <- function(text, x, y, xanchor, yanchor) {
    list(
      text = text, xref = "paper", yref = "paper", x = x, y = y, xanchor = xanchor, yanchor = yanchor,
      showarrow = FALSE, font = list(size = 12, color = ink)
    )
  }
  title <- if (summary$hours) {
    sprintf(
      "%.0f%% of %d hours in the comfort zone (%g-%g %s, %g-%g%%)",
      summary$comfortable, summary$hours, temperature_range[1], temperature_range[2], degrees_celsius,
      humidity_range[1], humidity_range[2]
    )
  } else {
    "No hours with both temperature and humidity"
  }
  plotly::plot_ly(
    x = both$temperature,
    y = both$humidity,
    type = "scatter",
    mode = "markers",
    marker = list(
      color = both$hour, cmin = 0, cmax = 24, colorscale = hour_colors, size = 7, opacity = 0.75,
      colorbar = list(
        title = list(text = "Hour"), thickness = 12,
        tickvals = seq(0, 18, 6), ticktext = hours[seq(1, 19, 6)]
      )
    ),
    text = hover,
    hovertemplate = "%{text}<extra></extra>"
  ) |>
    plotly::layout(
      title = title,
      xaxis = list(title = paste0("Temperature (", degrees_celsius, ")"), range = x_range, zeroline = FALSE),
      yaxis = list(title = "Humidity (%)", range = y_range, zeroline = FALSE),
      shapes = list(list(
        type = "rect", layer = "below",
        x0 = temperature_range[1], x1 = temperature_range[2], y0 = humidity_range[1], y1 = humidity_range[2],
        fillcolor = zone, opacity = 0.15, line = list(color = zone, width = 1.5)
      )),
      annotations = list(
        list(
          text = "comfort zone", x = mean(temperature_range), y = humidity_range[2], yanchor = "bottom",
          showarrow = FALSE, font = list(size = 12, color = zone)
        ),
        corner("cool and humid", 0.01, 0.99, "left", "top"),
        corner("warm and humid", 0.99, 0.99, "right", "top"),
        corner("cool and dry", 0.01, 0.01, "left", "bottom"),
        corner("warm and dry", 0.99, 0.01, "right", "bottom")
      ),
      margin = list(l = 80, r = 40, b = 60, t = 60)
    )
}
