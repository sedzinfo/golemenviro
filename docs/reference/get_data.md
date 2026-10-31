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
#> 1 2026-10-24 21:35:31 1792866931    28.58179 45.62881 1009.160   0        39
#> 2 2026-10-24 21:45:36 1792867536    28.54953 45.48142 1009.238   0        32
#> 3 2026-10-24 21:55:41 1792868141    28.59018 45.48176 1009.238   0        35
#> 4 2026-10-24 22:05:46 1792868746    28.46856 45.36896 1009.316   0        40
#> 5 2026-10-24 22:15:51 1792869351    28.35727 45.59156 1009.322   0        33
#> 6 2026-10-24 22:25:56 1792869956    28.50889 44.86911 1009.288   0        40
filtered_df <- get_data(start_time = start_time, end_time = end_time, urlq = prometheus_url[1])
head(filtered_df)
#>                  Date  Timestamp Temperature Humidity Pressure     Lux Proximity      NH3 Reducing Oxidising PM1 PM2.5 PM10
#> 1 2026-10-24 21:35:31 1792866931    28.46241 42.69484 1008.018 1.16185         7 72316.63 294124.3  93582.64  11    16   16
#> 2 2026-10-24 21:45:36 1792867536    28.56184 42.49412 1008.080 1.16185        11 71867.15 293132.1  93107.41  11    16   16
#> 3 2026-10-24 21:55:41 1792868141    28.45291 42.64444 1008.107 0.00000         8 72033.26 294622.6  93537.25  10    14   14
#> 4 2026-10-24 22:05:46 1792868746    28.42283 42.51561 1008.152 0.00000         5 72802.93 298023.0  94565.23  11    17   17
#> 5 2026-10-24 22:15:51 1792869351    28.35063 42.42568 1008.184 0.00000        17 73581.91 301360.4  95351.35  12    17   17
#> 6 2026-10-24 22:25:56 1792869956    28.37976 42.21335 1008.181 0.00000         9 73889.30 302791.4  95560.82  11    17   17
```
