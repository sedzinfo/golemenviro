# Comfort module - UI

A server and a period to pick, a chart of the temperature against the
humidity of every hour of the period over the comfortable ranges (see
[`plot_comfort()`](https://sedzinfo.github.io/golemenviro/reference/plot_comfort.md)),
and under it the shares of the hours that were too warm, too cool, too
dry or too humid. The chart has a full screen button (see
`inst/app/www/plot_zoom.js`).

## Usage

``` r
mod_comfort_ui(id, prometheus_url)
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
shiny::fluidPage(golemenviro:::mod_comfort_ui("comfort", "http://localhost:9090/api/v1/query_range"))
} # }
```
