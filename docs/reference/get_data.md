# Get Data from Prometheus

Downloads the readings of all the sensors of a Pimoroni Enviro or
Enviro+ from Prometheus, at about 1000 points in time between
`start_time` and `end_time`. When these are an hour or more apart (a
window of about 6 weeks or more), each point is the average of the
readings since the previous one, so that the day and night cycle does
not show up as noise; otherwise it is the reading at that time.

## Usage

``` r
get_data(
  start_time = format(Sys.time() - 60 * 60 * 24 * 7, "%Y-%m-%dT%H:%M:%SZ", tz =
    "UTC"),
  end_time = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
  urlq
)
```

## Arguments

- start_time:

  start time, in UTC, in this format: "2025-01-31T11:48:08Z"

- end_time:

  end time, in UTC, in this format: "2025-02-07T11:48:33Z"

- urlq:

  Prometheus url

## Value

A data frame with the Date and the Timestamp of the readings and one
column per sensor, or `NULL`, with a message, when the server cannot be
reached or sends no data. Sensors whose readings never change are left
out, as the device does not have them.

## Examples

``` r
prometheus_url <- c(
  "http://pip1.crabdance.com:1507/api/v1/query_range",
  "http://pip1.crabdance.com:1505/api/v1/query_range"
)
start_time <- format(Sys.time() - 60 * 60 * 24 * 7, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
end_time <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
filtered_df <- get_data(start_time = start_time, end_time = end_time, urlq = prometheus_url[2])
head(filtered_df)
#>                  Date  Timestamp Temperature Humidity Pressure Lux Proximity
#> 1 2026-10-24 21:27:09 1792866429    28.48856 45.90450 1009.191   0        40
#> 2 2026-10-24 21:37:14 1792867034    28.56695 45.65810 1009.198   0        38
#> 3 2026-10-24 21:47:19 1792867639    28.51889 45.39879 1009.219   0        43
#> 4 2026-10-24 21:57:24 1792868244    28.52566 45.59302 1009.240   0        37
#> 5 2026-10-24 22:07:29 1792868849    28.43760 45.51578 1009.310   0        38
#> 6 2026-10-24 22:17:34 1792869454    28.39501 45.36248 1009.364   0        40
filtered_df <- get_data(start_time = start_time, end_time = end_time, urlq = prometheus_url[1])
head(filtered_df)
#>                  Date  Timestamp Temperature Humidity Pressure     Lux Proximity      NH3 Reducing Oxidising PM1 PM2.5 PM10
#> 1 2026-10-24 21:27:09 1792866429    28.39718 42.82860 1008.046 1.16185         9 72083.17 293379.7  93582.64  10    14   14
#> 2 2026-10-24 21:37:14 1792867034    28.46653 42.70605 1008.023 1.16185        12 72033.26 293132.1  93355.96  11    16   16
#> 3 2026-10-24 21:47:19 1792867639    28.53113 42.52190 1008.091 1.16185         9 72049.89 293503.5  93265.49  10    14   14
#> 4 2026-10-24 21:57:24 1792868244    28.40541 42.72241 1008.112 0.00000         7 72183.12 294872.2  93469.21  10    15   15
#> 5 2026-10-24 22:07:29 1792868849    28.42695 42.47090 1008.182 0.00000        12 72920.86 299043.2  94703.36  12    16   16
#> 6 2026-10-24 22:17:34 1792869454    28.38103 42.40350 1008.202 0.00000         9 73530.82 300842.9  95328.11  11    14   15
```
