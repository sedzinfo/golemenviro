# The value colored white in the daily pattern of each metric

By metric name, the value that
[`plot_daily_pattern()`](https://sedzinfo.github.io/golemenviro/reference/plot_daily_pattern.md)
colors white, with lower values in blue and higher in red: room
temperature, the middle of the comfortable range of humidity (40 to 60\\
atmospheric pressure at sea level, and for particles the daily guideline
of the World Health Organization
([who_guidelines](https://sedzinfo.github.io/golemenviro/reference/who_guidelines.md)).
`NA` for the metrics with no such value (light, proximity, the gas
sensors, whose resistance is only relative, and PM1, which has no
guideline): these keep
[blue_steps](https://sedzinfo.github.io/golemenviro/reference/blue_steps.md).

## Usage

``` r
metric_mid
```

## Format

A named numeric vector, in the units of the readings.

## Examples

``` r
metric_mid
#> temperature    humidity    pressure         lux   proximity         NH3    reducing   oxidising         PM1        PM25        PM10 
#>       24.00       50.00     1013.25          NA          NA          NA          NA          NA          NA       15.00       45.00 
metric_mid[["temperature"]]
#> [1] 24
```
