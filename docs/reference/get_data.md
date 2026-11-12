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
#> 1 2026-11-05 15:53:59 1793886839    25.15600 45.53830 1017.116   0        37
#> 2 2026-11-05 16:04:04 1793887444    25.18696 45.71966 1017.172   0        44
#> 3 2026-11-05 16:14:09 1793888049    25.10696 46.64126 1017.171   0        43
#> 4 2026-11-05 16:24:14 1793888654    25.10116 45.93480 1017.100   0        42
#> 5 2026-11-05 16:34:19 1793889259    25.09696 46.09823 1017.101   0        38
#> 6 2026-11-05 16:44:24 1793889864    25.06664 46.44813 1017.144   0        37
filtered_df <- get_data(start_time = start_time, end_time = end_time, urlq = prometheus_url[1])
head(filtered_df)
#>                  Date  Timestamp Temperature Humidity Pressure Lux Proximity      NH3 Reducing Oxidising PM1 PM2.5 PM10
#> 1 2026-11-05 15:53:59 1793886839    28.88009 33.65611 1015.843   0        10 85711.00 330661.4  105230.2   4     6    6
#> 2 2026-11-05 16:04:04 1793887444    28.42536 33.92569 1015.884   0        13 87841.21 336669.3  107503.6   5     7    7
#> 3 2026-11-05 16:14:09 1793888049    28.68598 33.68114 1015.882   0        13 87110.21 333719.3  106855.3   3     5    5
#> 4 2026-11-05 16:24:14 1793888654    28.38103 33.89261 1015.847   0         4 87589.74 336044.6  108047.9   4     6    7
#> 5 2026-11-05 16:34:19 1793889259    28.90891 33.20664 1015.794   0         5 86324.91 332490.3  106052.0   4     7    7
#> 6 2026-11-05 16:44:24 1793889864    28.44753 33.83569 1015.853   0         8 86551.35 333257.5  106318.8   4     5    5
```
