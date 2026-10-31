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
#> 1 2026-10-24 20:15:42 1792862142    27.86920 46.66815 1009.292   0        36
#> 2 2026-10-24 20:25:47 1792862747    27.80211 46.99036 1009.277   0        41
#> 3 2026-10-24 20:35:52 1792863352    27.79856 46.81416 1009.276   0        34
#> 4 2026-10-24 20:45:57 1792863957    27.79049 46.83168 1009.248   0        38
#> 5 2026-10-24 20:56:02 1792864562    27.91275 48.20727 1009.287   0        38
#> 6 2026-10-24 21:06:07 1792865167    27.93566 47.67912 1009.266   0        39
filtered_df <- get_data(start_time = start_time, end_time = end_time, urlq = prometheus_url[1])
head(filtered_df)
#>                  Date  Timestamp Temperature Humidity Pressure     Lux Proximity      NH3 Reducing Oxidising PM1 PM2.5 PM10
#> 1 2026-10-24 20:15:42 1792862142    28.40130 43.16412 1008.127 0.00000        11 71141.38 289582.0  93559.94   9    12   12
#> 2 2026-10-24 20:25:47 1792862747    28.40098 43.08025 1008.149 0.00000         9 71289.16 290432.3  93992.39   9    12   12
#> 3 2026-10-24 20:35:52 1792863352    28.36235 43.09114 1008.193 0.00000         9 71404.34 290189.0  94038.06   9    12   12
#> 4 2026-10-24 20:45:57 1792863957    28.30978 43.10191 1008.116 0.00000        12 71767.70 290798.0  94198.11   9    13   13
#> 5 2026-10-24 20:56:02 1792864562    28.36520 43.10793 1008.163 1.16185        10 71420.81 289582.0  93696.23  10    13   13
#> 6 2026-10-24 21:06:07 1792865167    28.37185 43.24216 1008.142 1.16185        10 71784.26 291164.5  93673.50  11    14   15
```
