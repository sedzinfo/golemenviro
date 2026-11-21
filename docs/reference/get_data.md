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
#> 1 2026-11-14 15:26:38 1794662798    26.36404 53.52193 1010.361 0.00000        39
#> 2 2026-11-14 15:36:43 1794663403    26.23630 54.11411 1010.375 0.00000        40
#> 3 2026-11-14 15:46:48 1794664008    26.34146 54.61353 1010.470 0.00000        38
#> 4 2026-11-14 15:56:53 1794664613    26.67662 54.03897 1010.616 0.88715        41
#> 5 2026-11-14 16:06:58 1794665218    26.76791 54.10000 1010.694 0.00000        43
#> 6 2026-11-14 16:17:03 1794665823    26.83952 53.95000 1010.868 0.00000        39
filtered_df <- get_data(start_time = start_time, end_time = end_time, urlq = prometheus_url[1])
head(filtered_df)
#>                  Date  Timestamp Temperature Humidity Pressure Lux Proximity      NH3 Reducing Oxidising PM1 PM2.5 PM10
#> 1 2026-11-14 15:26:38 1794662798    28.64766 46.50425 1009.078   0        14 70213.34 283510.9  96357.40  13    24   26
#> 2 2026-11-14 15:36:43 1794663403    28.56343 46.67619 1009.047   0        12 70342.78 284802.2  96333.85   7    10   11
#> 3 2026-11-14 15:46:48 1794664008    28.23980 47.50296 1009.182   0        10 70537.42 286817.4  96333.85   7    11   11
#> 4 2026-11-14 15:56:53 1794664613    28.43423 47.18245 1009.324   0         8 70326.58 286817.4  95934.64   6     7    8
#> 5 2026-11-14 16:06:58 1794665218    28.66286 46.70009 1009.405   0        14 70391.38 286817.4  95165.64   5     8   10
#> 6 2026-11-14 16:17:03 1794665823    28.39021 47.35483 1009.575   0         8 70504.94 287774.0  95421.11   7     9    9
```
