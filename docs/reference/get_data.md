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
#> 1 2026-11-14 17:09:48 1794668988    26.67404 55.37716 1011.336   0        35
#> 2 2026-11-14 17:19:53 1794669593    26.68501 55.19636 1011.398   0        39
#> 3 2026-11-14 17:29:58 1794670198    26.70888 55.36071 1011.647   0        42
#> 4 2026-11-14 17:40:03 1794670803    26.76759 55.35085 1011.693   0        38
#> 5 2026-11-14 17:50:08 1794671408    26.78178 55.30454 1011.898   0        40
#> 6 2026-11-14 18:00:13 1794672013    26.90339 55.03938 1011.997   0        39
filtered_df <- get_data(start_time = start_time, end_time = end_time, urlq = prometheus_url[1])
head(filtered_df)
#>                  Date  Timestamp Temperature Humidity Pressure Lux Proximity      NH3 Reducing Oxidising PM1 PM2.5 PM10
#> 1 2026-11-14 17:09:48 1794668988    28.42188 47.94730 1010.090   0         9 69490.20 285038.1  93537.25   6    11   12
#> 2 2026-11-14 17:19:53 1794669593    28.57863 47.59805 1010.166   0         9 69538.15 285510.7  93537.25   5     8    8
#> 3 2026-11-14 17:29:58 1794670198    28.45228 48.18238 1010.346   0         6 69490.20 285274.2  92792.27   5     7    7
#> 4 2026-11-14 17:40:03 1794670803    28.28350 48.47499 1010.421   0        12 69394.40 284566.7  92949.68   8     9   11
#> 5 2026-11-14 17:50:08 1794671408    28.43581 48.05365 1010.612   0        12 69714.29 285392.4  93333.33   5     7    7
#> 6 2026-11-14 18:00:13 1794672013    28.40130 48.25399 1010.701   0         6 69378.45 284096.6  92859.69   7     9   10
```
