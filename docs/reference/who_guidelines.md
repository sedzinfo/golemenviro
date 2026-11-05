# The guidelines of the World Health Organization for particles

The air quality guidelines of 2021, in micrograms per cubic metre: for
the average of a day, which should not be exceeded on more than 3 to 4
days a year (the 99th percentile), and for the average of a year. PM1
has none.

## Usage

``` r
who_guidelines
```

## Format

A data frame with the columns `metric` (`"PM25"`, `"PM10"`), `day` and
`year`, in micrograms per cubic metre.

## Examples

``` r
who_guidelines
#>   metric day year
#> 1   PM25  15    5
#> 2   PM10  45   15
```
