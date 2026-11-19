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
#> 1 2026-11-12 14:51:27 1794487887    24.74342 53.12224 1008.572   0        39
#> 2 2026-11-12 15:01:32 1794488492    24.79697 52.89661 1008.557   0        38
#> 3 2026-11-12 15:11:37 1794489097    24.77955 53.01260 1008.460   0        37
#> 4 2026-11-12 15:21:42 1794489702    24.90310 52.56744 1008.294   0        38
#> 5 2026-11-12 15:31:47 1794490307    24.60472 53.38036 1008.431   0        38
#> 6 2026-11-12 15:41:52 1794490912    24.87858 52.78813 1008.378   0        43
filtered_df <- get_data(start_time = start_time, end_time = end_time, urlq = prometheus_url[1])
head(filtered_df)
#>                  Date  Timestamp Temperature Humidity Pressure Lux Proximity      NH3 Reducing Oxidising PM1 PM2.5 PM10
#> 1 2026-11-12 14:51:27 1794487887    26.96398 45.05798 1007.289   0        10 70407.59 265147.0  92255.11  17    23   23
#> 2 2026-11-12 15:01:32 1794488492    26.92693 45.09649 1007.189   0         9 70879.51 267147.5  92590.38  17    22   23
#> 3 2026-11-12 15:11:37 1794489097    26.73979 45.46710 1007.173   0         6 71503.23 270573.9  93650.77  14    18   19
#> 4 2026-11-12 15:21:42 1794489702    26.99691 45.00826 1007.032   0        10 71635.33 272862.2  93673.50  16    19   19
#> 5 2026-11-12 15:31:47 1794490307    26.93453 45.19685 1007.088   0        11 70977.58 271441.9  93129.97  16    20   20
#> 6 2026-11-12 15:41:52 1794490912    26.85663 45.40744 1007.093   0         5 71190.61 273411.8  93446.55  14    19   19
```
