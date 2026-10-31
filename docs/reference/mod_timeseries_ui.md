# Time Series module - UI

A server, a sensor and a period to pick (6 hours to 1 year), in the
order of the Daily Pattern tab, and a chart of that sensor, with a full
screen button (see `inst/app/www/plot_zoom.js`).

## Usage

``` r
mod_timeseries_ui(id, prometheus_url)
```

## Arguments

- id:

  Character. Module namespace id.

- prometheus_url:

  Character vector of Prometheus urls to choose from.

## Value

A `tagList` of Shiny UI elements.

## Examples

``` r
if (FALSE) { # \dontrun{
shiny::fluidPage(
  golemenviro:::mod_timeseries_ui("timeseries", "http://pip1.crabdance.com:1507/api/v1/query_range")
)
} # }
```
