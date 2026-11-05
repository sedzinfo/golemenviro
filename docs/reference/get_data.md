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
#> 1 2026-10-29 16:07:55 1793282875    25.15116 44.28246 1009.246   0        39
#> 2 2026-10-29 16:18:00 1793283480    25.33631 43.68759 1009.271   0        39
#> 3 2026-10-29 16:28:05 1793284085    25.28309 43.81587 1009.307   0        42
#> 4 2026-10-29 16:38:10 1793284690    25.21858 43.99078 1009.287   0        38
#> 5 2026-10-29 16:48:15 1793285295    25.11825 44.21796 1009.218   0        42
#> 6 2026-10-29 16:58:20 1793285900    25.23535 43.91492 1009.216   0        48
filtered_df <- get_data(start_time = start_time, end_time = end_time, urlq = prometheus_url[1])
head(filtered_df)
#>                  Date  Timestamp Temperature Humidity Pressure Lux Proximity      NH3 Reducing Oxidising PM1 PM2.5 PM10
#> 1 2026-10-29 16:07:55 1793282875    24.97951 42.29687 1008.100   0        13 79626.81 326311.9  95258.44   6     7    7
#> 2 2026-10-29 16:18:00 1793283480    25.12612 41.93704 1008.147   0        12 79776.28 327352.8  95654.10   5     6    6
#> 3 2026-10-29 16:28:05 1793284085    25.01276 42.05288 1008.124   0        10 79963.58 327950.1  95981.50   6     9    9
#> 4 2026-10-29 16:38:10 1793284690    25.13024 41.78714 1008.133   0        11 80019.87 328399.4  96028.38   6    10   10
#> 5 2026-10-29 16:48:15 1793285295    24.82435 42.30682 1008.076   0         5 79982.34 328549.4  96122.24   6     8    8
#> 6 2026-10-29 16:58:20 1793285900    24.83417 42.24586 1008.049   0        10 80226.68 329451.7  96475.25   6     7    7
```
