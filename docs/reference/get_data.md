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
#> 1 2026-11-01 21:15:17 1793560517    26.42824 53.00363 1008.383   0        45
#> 2 2026-11-01 21:25:22 1793561122    26.34695 53.15922 1008.398   0        35
#> 3 2026-11-01 21:35:27 1793561727    26.35243 52.94907 1008.375   0        40
#> 4 2026-11-01 21:45:32 1793562332    26.25017 53.40202 1008.424   0        40
#> 5 2026-11-01 21:55:37 1793562937    26.38630 53.14277 1008.403   0        41
#> 6 2026-11-01 22:05:42 1793563542    26.35275 53.04840 1008.386   0        41
filtered_df <- get_data(start_time = start_time, end_time = end_time, urlq = prometheus_url[1])
head(filtered_df)
#>                  Date  Timestamp Temperature Humidity Pressure Lux Proximity      NH3 Reducing Oxidising PM1 PM2.5 PM10
#> 1 2026-11-01 21:15:17 1793560517    26.24960 50.33370 1007.263   0         9 71190.61 278668.9  86902.71  11    15   16
#> 2 2026-11-01 21:25:22 1793561122    26.26512 50.23413 1007.244   0        10 71289.16 278896.4  87318.31  12    16   16
#> 3 2026-11-01 21:35:27 1793561727    26.38576 50.13154 1007.249   0         5 69955.27 268744.6  86140.18  49    93   98
#> 4 2026-11-01 21:45:32 1793562332    26.48773 50.05622 1007.263   0         2 68696.36 257885.4  85243.91  67   115  116
#> 5 2026-11-01 21:55:37 1793562937    26.32465 50.42441 1007.298   0         5 68712.13 258787.6  85203.44  44    78   81
#> 6 2026-11-01 22:05:42 1793563542    26.15714 50.82548 1007.260   0         9 68649.05 259089.5  85183.21  26    42   42
```
