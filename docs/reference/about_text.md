# The text of the About tab

Reads `inst/app/about.md` and fills in the time zone of the app, in
which the tabs show the times.

## Usage

``` r
about_text()
```

## Value

The Markdown text, as one string.

## Examples

``` r
cat(substr(golemenviro:::about_text(), 1, 300))
#> This app shows the readings of Pimoroni Enviro and Enviro+ sensor boards on a Raspberry Pi, as their Prometheus servers keep them. Each server in the Server box at the top of a tab is one device. Times are in Europe/Athens.
#> 
#> **On this page:** [Current](#about-current) · [Time Series](#about-timeseri
```
