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
#> 1 2026-10-29 16:38:00 1793284680    25.21858 43.99078 1009.287   0        38
#> 2 2026-10-29 16:48:05 1793285285    25.17406 44.01971 1009.245   0        44
#> 3 2026-10-29 16:58:10 1793285890    25.21922 43.94988 1009.198   0        35
#> 4 2026-10-29 17:08:15 1793286495    25.18632 43.96720 1009.280   0        38
#> 5 2026-10-29 17:18:20 1793287100    25.09922 44.67927 1009.343   0        34
#> 6 2026-10-29 17:28:25 1793287705    25.24696 44.45843 1009.455   0        41
filtered_df <- get_data(start_time = start_time, end_time = end_time, urlq = prometheus_url[1])
head(filtered_df)
#>                  Date  Timestamp Temperature Humidity Pressure Lux Proximity      NH3 Reducing Oxidising PM1 PM2.5 PM10
#> 1 2026-10-29 16:38:00 1793284680    25.13024 41.78714 1008.133   0        11 80019.87 328399.4  96028.38   6    10   10
#> 2 2026-10-29 16:48:05 1793285285    24.82435 42.30682 1008.076   0         5 79982.34 328549.4  96122.24   6     8    8
#> 3 2026-10-29 16:58:10 1793285890    24.83417 42.24586 1008.049   0        10 80226.68 329451.7  96475.25   6     7    7
#> 4 2026-10-29 17:08:15 1793286495    25.12454 41.59275 1008.146   0         7 80415.22 330206.9  96711.50   5     8    8
#> 5 2026-10-29 17:18:20 1793287100    24.98901 41.81402 1008.218   0         6 80358.61 329602.5  96664.19   4     7    8
#> 6 2026-10-29 17:28:25 1793287705    24.99281 41.69192 1008.301   0        10 80471.89 330358.3  96711.50   6     7    7
```
