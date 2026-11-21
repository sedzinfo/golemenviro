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
#> 1 2026-11-14 17:36:59 1794670619    26.72791 55.11587 1011.692   0        34
#> 2 2026-11-14 17:47:04 1794671224    26.58178 55.66051 1011.812   0        39
#> 3 2026-11-14 17:57:09 1794671829    26.81146 55.14180 1011.925   0        42
#> 4 2026-11-14 18:07:14 1794672434    26.90791 55.47212 1012.030   0        37
#> 5 2026-11-14 18:17:19 1794673039    26.34985 56.83803 1012.207   0        42
#> 6 2026-11-14 18:27:24 1794673644    26.37533 56.87393 1012.364   0        40
filtered_df <- get_data(start_time = start_time, end_time = end_time, urlq = prometheus_url[1])
head(filtered_df)
#>                  Date  Timestamp Temperature Humidity Pressure Lux Proximity      NH3 Reducing Oxidising PM1 PM2.5 PM10
#> 1 2026-11-14 17:36:59 1794670619    28.44246 48.27712 1010.409   0        12 69506.18 285747.6  93084.86   7    10   10
#> 2 2026-11-14 17:47:04 1794671224    28.40288 48.18703 1010.530   0         8 69602.14 285156.1  93220.29   5     7    7
#> 3 2026-11-14 17:57:09 1794671829    28.48616 48.07134 1010.667   0        15 69394.40 284802.2  93333.33   6     9    9
#> 4 2026-11-14 18:07:14 1794672434    28.45735 48.19923 1010.742   0         6 69330.62 283393.9  92792.27   6    10   10
#> 5 2026-11-14 18:17:19 1794673039    28.48521 48.36170 1010.923   0        13 68949.29 282113.2  92255.11  22    35   37
#> 6 2026-11-14 18:27:24 1794673644    28.70371 47.98602 1011.072   0        13 67850.21 273852.7  90972.86  22    41   44
```
