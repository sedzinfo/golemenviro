# Air Quality module - server

Downloads the daily averages of PM2.5 and PM10 when the server or the
period changes, and shows how many days were above the guideline of the
World Health Organization for a day, the average of the period against
the guideline for a year, and the bars of the days. When the server
cannot be reached, or the device has no particle sensor, the tab says
so.

## Usage

``` r
mod_air_quality_server(id, dark_mode)
```

## Arguments

- id:

  Character. Module namespace id, must match the id used in
  [`mod_air_quality_ui()`](https://sedzinfo.github.io/golemenviro/reference/mod_air_quality_ui.md).

- dark_mode:

  Reactive returning `"light"` or `"dark"`, the mode of the app, for the
  colors of the bars.

## Value

None. Called for its side effect of registering the module server.

## Examples

``` r
if (FALSE) { # \dontrun{
# inside app_server():
mod_air_quality_server("air_quality", reactive(if (isTRUE(input$dark_mode)) "dark" else "light"))
} # }
```
