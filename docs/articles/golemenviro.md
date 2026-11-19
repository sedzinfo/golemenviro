# Gauges and time series

The charts of the [golemenviro
app](https://sedzinfo-golemenviro.share.connect.posit.cloud/) are also R
functions. Each one takes readings downloaded from a Prometheus server
and returns an interactive [plotly](https://plotly.com/r/) chart. Run it
in the console and the chart opens in the RStudio Viewer or your
browser. In an R Markdown or Quarto document it appears in the page.

This article shows the gauges of the Current tab and the chart of the
Time Series tab. [Daily pattern and
comfort](https://sedzinfo.github.io/golemenviro/articles/daily-pattern.md)
shows the charts of the hourly averages, and [Air
quality](https://sedzinfo.github.io/golemenviro/articles/air-quality.md)
the daily averages of the particles against the guidelines of the World
Health Organization.

## Install and load the package

``` r

install.packages("golemenviro",
  repos = c("https://sedzinfo.r-universe.dev", "https://cloud.r-project.org"))
```

``` r

library(golemenviro)
```

## The servers

Each device runs
[enviroplus_exporter](https://github.com/tijmenvandenbrink/enviroplus_exporter),
which reads its sensors, and a Prometheus server, which collects and
keeps the readings. The functions take the `query_range` address of that
server. The two servers of the live app need no API key or password:

``` r

prometheus_url <- c(
  "http://pip1.crabdance.com:1507/api/v1/query_range",
  "http://pip1.crabdance.com:1505/api/v1/query_range"
)
```

The first device has all the sensors of an Enviro+. The second, like an
Enviro, has no gas or particle sensors. The
[README](https://github.com/sedzinfo/golemenviro#readme) shows how to
set up a device of your own.

## Time zone

The functions show the times in the time zone of your R session, which
[`app_time_zone()`](https://sedzinfo.github.io/golemenviro/reference/app_time_zone.md)
returns. The app shows them in the time zone given to
[`pimoroni()`](https://sedzinfo.github.io/golemenviro/reference/pimoroni.md),
`"Europe/Bucharest"` by default. To see the same times as the app, set
it at the start of the session:

``` r

Sys.setenv(TZ = "Europe/Bucharest")
app_time_zone()
#> [1] "Europe/Bucharest"
```

## Download the readings

[`get_data()`](https://sedzinfo.github.io/golemenviro/reference/get_data.md)
downloads the readings of all the sensors of one server, by default over
the last 7 days:

``` r

week <- get_data(urlq = prometheus_url[1])
names(week)
#>  [1] "Date"        "Timestamp"   "Temperature" "Humidity"    "Pressure"    "Lux"         "Proximity"   "NH3"         "Reducing"    "Oxidising"   "PM1"         "PM2.5"       "PM10"
tail(week[, c("Date", "Temperature", "Humidity", "Pressure", "PM2.5")], 3)
#>                     Date Temperature Humidity Pressure PM2.5
#> 998  2026-11-19 14:17:30    28.15113 43.44154 1002.216     5
#> 999  2026-11-19 14:27:35    28.48205 42.56074 1002.034     5
#> 1000 2026-11-19 14:37:40    28.17583 43.00584 1001.933     5
```

It returns about 1,000 rows: over 7 days, a reading every 10 minutes.
`Date` is the time of the reading and `Timestamp` the same time in
seconds, followed by a column per sensor.

Sensors whose readings never change are left out, as the device does not
have them. The second server has no columns for the gases and the
particles:

``` r

names(get_data(urlq = prometheus_url[2]))
#> [1] "Date"        "Timestamp"   "Temperature" "Humidity"    "Pressure"    "Lux"         "Proximity"
```

When a server cannot be reached, or sends no data,
[`get_data()`](https://sedzinfo.github.io/golemenviro/reference/get_data.md)
returns `NULL` with a message.

## Gauges

[`plot_gauge()`](https://sedzinfo.github.io/golemenviro/reference/plot_gauge.md)
draws the last reading of one sensor as a gauge, as the Current tab
does. `variable` is the name of its column:

``` r

plot_gauge(week, "Temperature")
```

The big number is the last reading, and the small one under it its
difference from the reference point, the thin line across the gauge. The
green band is a comfortable or recommended range: 20 to 25 °C, 40 to 60%
humidity, 1,010 to 1,015 hPa and 1,000 to 1,500 lux.

For PM2.5 and PM10 the green band reaches up to the guideline of the
World Health Organization for the average of a day. PM1, which has none,
gets that of PM2.5. A note under the gauges of the particles and the
gases says what they measure:

``` r

plot_gauge(week, "PM2.5")
```

The gas and proximity sensors have no fixed scale, so their gauge is
scaled to all the readings you pass: from the lowest to the highest,
widened by one standard deviation. The green band is the mean plus or
minus one standard deviation, and the reference point is the mean. The
app passes the last 7 days, as here:

``` r

plot_gauge(week, "Reducing")
```

## Time series

[`plot_time_series()`](https://sedzinfo.github.io/golemenviro/reference/plot_time_series.md)
draws the readings of one sensor, as the Time Series tab does, with
their moving average and their mean. On the right it sums them up: the
last reading, the mean (μ), the minimum and maximum, the standard
deviation (σ), the range, and the first and last day. `scale` is the
title of the y axis:

``` r

plot_time_series(week, "Temperature", scale = degrees_celsius)
```

`degrees_celsius` and `micrograms_m3` hold the units with their special
characters, as `symbol_mean` and `symbol_sd` hold μ and σ.

The moving average, Smoothing, is the mean of `k` readings centred on
each one, 30 by default: about 5 hours over 7 days. A larger `k` smooths
more.

For another period, pass its start, and its end if not now, with
`start_time` and `end_time`. They are in UTC, written as
`"2025-01-31T11:48:08Z"`. Whatever the period,
[`get_data()`](https://sedzinfo.github.io/golemenviro/reference/get_data.md)
returns about 1,000 readings, so a chart of a year is as light as one of
a week:

``` r

a_year_ago <- Sys.time() - 365 * 24 * 60 * 60
start_time <- format(a_year_ago, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
year <- get_data(start_time = start_time, urlq = prometheus_url[1])
plot_time_series(year, "PM2.5", scale = micrograms_m3)
```

From about 6 weeks on, the readings are an hour or more apart, and each
is the average of the readings since the previous one, so short spikes
are averaged away. Over a year each one covers almost 9 hours, and the
moving average about 11 days.

## Save or change a chart

The charts are plotly objects, so the functions of the plotly and
htmlwidgets packages work on them. To save a chart as a web page that
opens in any browser:

``` r

chart <- plot_time_series(week, "Temperature", scale = degrees_celsius)
htmlwidgets::saveWidget(chart, "temperature.html")
```

To change the layout, for example the title:

``` r

plotly::layout(chart, title = "Temperature over the last week")
```

## Run the app

[`pimoroni()`](https://sedzinfo.github.io/golemenviro/reference/pimoroni.md)
starts the app with the servers you give it and opens it in your
browser. Its `timezone` argument sets the time zone of the app:

``` r

pimoroni(prometheus_url = prometheus_url)
```
