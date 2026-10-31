# Daily Pattern module - server

Downloads the hourly averages of the picked sensor and draws them, or
says why it cannot: the server cannot be reached, it has no readings of
the sensor in that period, or they never change, as for the gas sensors
of an Enviro, which has none.

## Usage

``` r
mod_daily_pattern_server(id, dark_mode)
```

## Arguments

- id:

  Character. Module namespace id, must match the id used in
  [`mod_daily_pattern_ui()`](https://sedzinfo.github.io/golemenviro/reference/mod_daily_pattern_ui.md).

- dark_mode:

  Reactive returning `"light"` or `"dark"`, the mode of the app, for the
  colors of the heatmap.

## Value

None. Called for its side effect of registering the module server.

## Examples

``` r
if (FALSE) { # \dontrun{
# inside app_server():
mod_daily_pattern_server("daily_pattern", reactive(if (isTRUE(input$dark_mode)) "dark" else "light"))
} # }
```
