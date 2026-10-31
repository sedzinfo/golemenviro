# Daily Pattern module - UI

A server, a sensor and a period to pick, a heatmap of the hourly
averages of that sensor, a column per day and a row per hour, and below
it a typical day: the median of each hour and the range of its middle
half. Each chart has a full screen button (see
`inst/app/www/plot_zoom.js`).

## Usage

``` r
mod_daily_pattern_ui(id, prometheus_url)
```

## Arguments

- id:

  Character. Module namespace id.

- prometheus_url:

  Prometheus query_range urls to choose from.

## Value

A `tagList` of Shiny UI elements.

## Examples

``` r
if (FALSE) { # \dontrun{
shiny::fluidPage(golemenviro:::mod_daily_pattern_ui("daily_pattern", "http://localhost:9090/api/v1/query_range"))
} # }
```
