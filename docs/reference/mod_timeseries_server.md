# Time Series module - server

Downloads the readings of all the sensors for the chosen number of days
when the server or the number of days changes, so that picking another
sensor draws it without downloading again, and renders the chart of the
picked sensor. When the server cannot be reached, or the device does not
have the sensor, the chart says so.

## Usage

``` r
mod_timeseries_server(id)
```

## Arguments

- id:

  Character. Module namespace id, must match the id used in
  [`mod_timeseries_ui()`](https://sedzinfo.github.io/golemenviro/reference/mod_timeseries_ui.md).

## Value

None. Called for its side effect of registering the module server.

## Examples

``` r
if (FALSE) { # \dontrun{
# inside app_server():
function(input, output, session) {
  mod_timeseries_server("timeseries")
}
} # }
```
