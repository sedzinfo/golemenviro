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
#> 1 2026-11-12 15:03:09 1794488589    24.90471 52.59661 1008.518   0        38
#> 2 2026-11-12 15:13:14 1794489194    24.89245 52.86420 1008.398   0        44
#> 3 2026-11-12 15:23:19 1794489799    24.86665 52.91593 1008.307   0        39
#> 4 2026-11-12 15:33:24 1794490404    24.73955 53.06974 1008.435   0        46
#> 5 2026-11-12 15:43:29 1794491009    24.86987 52.82866 1008.355   0        42
#> 6 2026-11-12 15:53:34 1794491614    24.81149 52.89700 1008.268   0        43
filtered_df <- get_data(start_time = start_time, end_time = end_time, urlq = prometheus_url[1])
head(filtered_df)
#>                  Date  Timestamp Temperature Humidity Pressure Lux Proximity      NH3 Reducing Oxidising PM1 PM2.5 PM10
#> 1 2026-11-12 15:03:09 1794488589    27.02161 44.88043 1007.165   0         6 70456.25 266618.7  92657.62  15    22   22
#> 2 2026-11-12 15:13:14 1794489194    26.81895 45.36239 1007.130   0         6 70846.85 269280.5  93265.49  16    19   19
#> 3 2026-11-12 15:23:19 1794489799    27.01749 44.94723 1007.000   0         7 70928.53 270465.7  93333.33  15    19   19
#> 4 2026-11-12 15:33:24 1794490404    26.98044 45.13617 1007.126   0        10 70993.94 271659.6  93062.31  15    20   20
#> 5 2026-11-12 15:43:29 1794491009    26.96556 45.12484 1007.077   0        13 71950.15 275405.5  93878.35  13    18   18
#> 6 2026-11-12 15:53:34 1794491614    26.96176 45.09137 1006.987   0         9 71404.34 274516.4  93855.56  13    18   18
```
