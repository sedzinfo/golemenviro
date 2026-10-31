# Get the daily averages of one sensor

The average of the hourly averages of each whole day, midnight to
midnight in the time zone of the app, of the `days` days before today,
for the Air Quality tab. Today, still running, is left out, and so is a
day with readings in fewer than 18 of its hours (75%), as in the usual
rules for daily averages of air quality.

## Usage

``` r
get_daily(urlq, metric, days = 30, end_time = Sys.time())
```

## Arguments

- urlq:

  Prometheus query_range url.

- metric:

  Name of the metric, one of `metrics`.

- days:

  Number of days, up to the start of the current hour.

- end_time:

  A time on the day after the last day, by default now.

## Value

A data frame with one row per day: `date` (a Date), `value` (the
average) and `hours` (how many hours had readings). It has no rows when
no day has enough readings, and is `NULL`, with a message, when the
server cannot be reached.

## Examples

``` r
if (FALSE) { # \dontrun{
url <- "http://pip1.crabdance.com:1507/api/v1/query_range"
get_daily(url, "PM25", days = 30)
} # }
```
