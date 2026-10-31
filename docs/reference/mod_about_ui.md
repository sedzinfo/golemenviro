# About module - UI

What each tab shows, what the sensors measure and how to read their
numbers, from
[`about_text()`](https://sedzinfo.github.io/golemenviro/reference/about_text.md).

## Usage

``` r
mod_about_ui(id)
```

## Arguments

- id:

  Character. Module namespace id.

## Value

A `div` of Shiny UI elements.

## Examples

``` r
if (FALSE) { # \dontrun{
shiny::fluidPage(golemenviro:::mod_about_ui("about"))
} # }
```
