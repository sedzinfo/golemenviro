# Steps of one red, from light to dark

The red counterpart of
[blue_steps](https://sedzinfo.github.io/golemenviro/reference/blue_steps.md),
with the same lightness at each step, for scales where higher means
hotter or worse. Reverse it with `rev(red_steps)` in dark mode, as
[`plot_daily_pattern()`](https://sedzinfo.github.io/golemenviro/reference/plot_daily_pattern.md)
does with blue.

## Usage

``` r
red_steps
```

## Format

A character vector of 5 hexadecimal colors.

## Examples

``` r
red_steps
#> [1] "#fbd3cf" "#f28d84" "#e0463b" "#a91f17" "#660d08"
# as a plotly color scale
lapply(seq_along(red_steps), function(i) list((i - 1) / 4, red_steps[i]))
#> [[1]]
#> [[1]][[1]]
#> [1] 0
#> 
#> [[1]][[2]]
#> [1] "#fbd3cf"
#> 
#> 
#> [[2]]
#> [[2]][[1]]
#> [1] 0.25
#> 
#> [[2]][[2]]
#> [1] "#f28d84"
#> 
#> 
#> [[3]]
#> [[3]][[1]]
#> [1] 0.5
#> 
#> [[3]][[2]]
#> [1] "#e0463b"
#> 
#> 
#> [[4]]
#> [[4]][[1]]
#> [1] 0.75
#> 
#> [[4]][[2]]
#> [1] "#a91f17"
#> 
#> 
#> [[5]]
#> [[5]][[1]]
#> [1] 1
#> 
#> [[5]][[2]]
#> [1] "#660d08"
#> 
#> 
```
