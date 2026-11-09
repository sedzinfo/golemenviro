# Share of hours in and around the comfort zone

Pairs the hourly averages of temperature and humidity by hour and counts
how many hours fall inside the comfortable ranges, and how many are too
warm, too cool, too dry or too humid (an hour can be both too warm and
too dry).

## Usage

``` r
comfort_summary(
  temperature,
  humidity,
  temperature_range = c(20, 25),
  humidity_range = c(40, 60)
)
```

## Arguments

- temperature, humidity:

  Data frames from
  [`get_hourly()`](https://sedzinfo.github.io/golemenviro/reference/get_hourly.md)
  of temperature and humidity.

- temperature_range, humidity_range:

  The comfortable ranges, the same as the green bands of the Current
  tab: 20 to 25 degrees Celsius and 40 to 60%.

## Value

A list: `hours`, the number of hours with both readings, and the
percentages `comfortable`, `too_warm`, `too_cool`, `too_dry` and
`too_humid`.

## Examples

``` r
hours <- expand.grid(hour = 0:23, date = as.Date("2026-10-01") + 0:6)
temperature <- transform(hours, value = 22 + 4 * sin((hour - 9) / 24 * 2 * pi))
humidity <- transform(hours, value = 45 - 8 * sin((hour - 9) / 24 * 2 * pi))
comfort_summary(temperature, humidity)
#> $hours
#> [1] 168
#> 
#> $comfortable
#> [1] 41.66667
#> 
#> $too_warm
#> [1] 20.83333
#> 
#> $too_cool
#> [1] 29.16667
#> 
#> $too_dry
#> [1] 29.16667
#> 
#> $too_humid
#> [1] 0
#> 
```
