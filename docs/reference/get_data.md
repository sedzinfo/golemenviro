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
#>                  Date  Timestamp Temperature Humidity Pressure     Lux Proximity
#> 1 2026-11-13 11:07:03 1794560823    25.30954 58.12914 1009.365 0.00000        48
#> 2 2026-11-13 11:17:08 1794561428    25.32406 58.04236 1009.325 0.88715        42
#> 3 2026-11-13 11:27:13 1794562033    25.36567 57.68302 1009.116 0.00000        42
#> 4 2026-11-13 11:37:18 1794562638    25.35760 57.79915 1009.191 0.00000        39
#> 5 2026-11-13 11:47:23 1794563243    25.35664 57.55461 1009.103 0.00000        35
#> 6 2026-11-13 11:57:28 1794563848    25.38631 57.27039 1009.094 0.00000        40
filtered_df <- get_data(start_time = start_time, end_time = end_time, urlq = prometheus_url[1])
head(filtered_df)
#>                  Date  Timestamp Temperature Humidity Pressure Lux Proximity      NH3 Reducing Oxidising PM1 PM2.5 PM10
#> 1 2026-11-13 11:07:03 1794560823    27.64036 48.35076 1008.045   0         6 69538.15 274405.6  87485.22   5     7    7
#> 2 2026-11-13 11:17:08 1794561428    27.69546 48.18462 1008.056   0         8 70229.51 276973.0  88051.45   4     5    5
#> 3 2026-11-13 11:27:13 1794562033    27.62104 48.26678 1007.856   0         4 69810.57 276635.8  88093.57   5     8    8
#> 4 2026-11-13 11:37:18 1794562638    27.72174 47.99559 1007.967   0        12 70051.92 278328.4  88241.18   6     9    9
#> 5 2026-11-13 11:47:23 1794563243    27.56215 48.29907 1007.846   0        13 70781.58 281187.8  88941.18   5     8    8
#> 6 2026-11-13 11:57:28 1794563848    27.67298 47.93892 1007.866   0         9 70278.03 280727.0  88813.40   6     7    7
```
