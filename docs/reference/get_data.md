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
#> 1 2026-11-12 16:07:53 1794492473    24.87536 52.98605 1008.275   0        49
#> 2 2026-11-12 16:17:58 1794493078    24.76826 53.04140 1008.311   0        40
#> 3 2026-11-12 16:28:03 1794493683    24.90536 52.81213 1008.236   0        41
#> 4 2026-11-12 16:38:08 1794494288    24.79149 53.29820 1008.103   0        42
#> 5 2026-11-12 16:48:13 1794494893    24.86568 53.14301 1008.165   0        34
#> 6 2026-11-12 16:58:18 1794495498    24.98277 52.95979 1008.072   0        42
filtered_df <- get_data(start_time = start_time, end_time = end_time, urlq = prometheus_url[1])
head(filtered_df)
#>                  Date  Timestamp Temperature Humidity Pressure Lux Proximity      NH3 Reducing Oxidising PM1 PM2.5 PM10
#> 1 2026-11-12 16:07:53 1794492473    26.85315 45.49092 1007.001   0         9 72299.92 279352.2  94565.23  14    18   18
#> 2 2026-11-12 16:17:58 1794493078    27.09159 45.01502 1006.968   0        11 71751.13 278215.0  94038.06  13    17   17
#> 3 2026-11-12 16:28:03 1794493683    26.91648 45.38040 1006.941   0        10 71503.23 278328.4  93901.14  12    17   17
#> 4 2026-11-12 16:38:08 1794494288    26.96588 45.38664 1006.837   0         4 72685.21 283043.7  94680.32  10    14   15
#> 5 2026-11-12 16:48:13 1794494893    26.79678 45.69614 1006.829   0        12 72016.63 281649.9  94749.46  12    16   16
#> 6 2026-11-12 16:58:18 1794495498    27.06563 45.18741 1006.742   0        14 72988.35 285156.1  94934.15  10    14   14
```
