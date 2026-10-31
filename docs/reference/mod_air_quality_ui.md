# Air Quality module - UI

A server and a period to pick, the number of days of the period above
the guideline of the World Health Organization for the average of a day,
for PM2.5 and PM10, and a bar chart of their daily averages, each with a
full screen button (see `inst/app/www/plot_zoom.js`).

## Usage

``` r
mod_air_quality_ui(id, prometheus_url)
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
shiny::fluidPage(golemenviro:::mod_air_quality_ui("air_quality", "http://localhost:9090/api/v1/query_range"))
} # }
```
