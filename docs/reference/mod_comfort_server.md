# Comfort module - server

Downloads the hourly averages of temperature and humidity and draws them
against the comfortable ranges, or says why it cannot: the server cannot
be reached, or it has no readings of one of the two in that period.

## Usage

``` r
mod_comfort_server(id, dark_mode)
```

## Arguments

- id:

  Character. Module namespace id, must match the id used in
  [`mod_comfort_ui()`](https://sedzinfo.github.io/golemenviro/reference/mod_comfort_ui.md).

- dark_mode:

  Reactive returning `"light"` or `"dark"`, the mode of the app, for the
  colors of the chart.

## Value

None. Called for its side effect of registering the module server.

## Examples

``` r
if (FALSE) { # \dontrun{
# inside app_server():
mod_comfort_server("comfort", reactive(if (isTRUE(input$dark_mode)) "dark" else "light"))
} # }
```
