# Get the hourly averages of one sensor

Asks Prometheus for the average of each clock hour of the last `days`
days, for the Daily Pattern tab. The average Prometheus gives at a time
covers the hour before it, so it is filed under the hour that starts one
hour earlier, in the time zone of the app.

## Usage

``` r
get_hourly(urlq, metric, days = 30, end_time = Sys.time())
```

## Arguments

- urlq:

  Prometheus query_range url.

- metric:

  Name of the metric, one of `metrics`.

- days:

  Number of days, up to the start of the current hour.

- end_time:

  The time to count back from, by default now.

## Value

A data frame with one row per hour: `date` (a Date), `hour` (0 to 23)
and `value`. It has no rows when the server has no readings of the
metric in that time, and is `NULL`, with a message, when the server
cannot be reached.

## Examples

``` r
if (FALSE) { # \dontrun{
url <- "http://pip1.crabdance.com:1507/api/v1/query_range"
get_hourly(url, "temperature", days = 7)
} # }
```
