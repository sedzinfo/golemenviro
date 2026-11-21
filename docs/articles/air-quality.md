# Air quality

The Air Quality tab of the [golemenviro
app](https://sedzinfo-golemenviro.share.connect.posit.cloud/) compares
the particles with the air quality guidelines of the World Health
Organization (2021). The guidelines are for the averages of whole days
and years, not for single readings. In R,
[`get_daily()`](https://sedzinfo.github.io/golemenviro/reference/get_daily.md)
downloads the averages of the days, `who_guidelines` holds the
guidelines, and
[`plot_daily_means()`](https://sedzinfo.github.io/golemenviro/reference/plot_daily_means.md)
draws the days against them. [Gauges and time
series](https://sedzinfo.github.io/golemenviro/articles/golemenviro.md)
shows how to install the package and which servers it reads.

[`library`](https://rdrr.io/r/base/library.html)`(`[`golemenviro`](https://sedzinfo.github.io/golemenviro/)`)`` `[`Sys.setenv`](https://rdrr.io/r/base/Sys.setenv.html)`(``TZ ``=`` ``"Europe/Bucharest"``)`` ``url`` ``<-`` ``"http://pip1.crabdance.com:1507/api/v1/query_range"`

The days run from midnight to midnight in the time zone of the R
session, here the one of the app, as [Gauges and time
series](https://sedzinfo.github.io/golemenviro/articles/golemenviro.html#time-zone)
explains.

## The guidelines

`who_guidelines`` ``#> metric day year`` ``#> 1 PM25 15 5`` ``#> 2 PM10 45 15`

`day` is the guideline for the average of a day, which should not be
exceeded on more than 3 to 4 days a year, and `year` the one for the
average of a year, both in µg/m³. PM1 has none.

## Download the daily averages

[`get_daily()`](https://sedzinfo.github.io/golemenviro/reference/get_daily.md)
downloads the average of each whole day of one sensor, over the `days`
days before today, 30 by default. Like
[`get_hourly()`](https://sedzinfo.github.io/golemenviro/reference/get_hourly.md),
it takes the name of the sensor in Prometheus, `"PM25"` for PM2.5.
Today, still running, is left out, and so is a day with readings in
fewer than 18 of its hours, as in the usual rules for daily averages of
air quality:

`pm25`` ``<-`` `[`get_daily`](https://sedzinfo.github.io/golemenviro/reference/get_daily.md)`(``url``, ``"PM25"``, days ``=`` ``30``)`` `[`tail`](https://rdrr.io/r/utils/head.html)`(``pm25``)`` ``#> date value hours`` ``#> 25 2026-11-15 16.05972 24`` ``#> 26 2026-11-16 17.94028 24`` ``#> 27 2026-11-17 19.78750 24`` ``#> 28 2026-11-18 11.55347 24`` ``#> 29 2026-11-19 19.13194 24`` ``#> 30 2026-11-20 16.12361 24`

It has a row per day: its `date`, the average `value`, and how many
`hours` had readings. When the server cannot be reached,
[`get_daily()`](https://sedzinfo.github.io/golemenviro/reference/get_daily.md)
returns `NULL` with a message.

## Days against the guideline

[`plot_daily_means()`](https://sedzinfo.github.io/golemenviro/reference/plot_daily_means.md)
draws the days of a particle sensor as bars, with the guideline for a
day as a dashed line, so that the days above it stand out. `variable`
names the sensor in the title and the hover labels, and `guideline` sets
the line. The axis starts at 0 and always reaches above the guideline:

`guideline`` ``<-`` ``who_guidelines``$``day``[``who_guidelines``$``metric`` ``==`` ``"PM25"``]`` `[`plot_daily_means`](https://sedzinfo.github.io/golemenviro/reference/plot_daily_means.md)`(``pm25``, ``"PM2.5"``, ``guideline``)`

The app counts the days above the guideline, and sets the average of the
period against the guideline for a year:

[`sum`](https://rdrr.io/r/base/sum.html)`(``pm25``$``value`` ``>`` ``guideline``)`` ``#> [1] 18`` `[`round`](https://rdrr.io/r/base/Round.html)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``pm25``$``value``)``, ``1``)`` ``#> [1] 18.3`

The guideline for a year is for the average of a whole year, so for a
shorter period it is only a pointer.

## A year of PM10

For a longer period, raise `days`:

`pm10`` ``<-`` `[`get_daily`](https://sedzinfo.github.io/golemenviro/reference/get_daily.md)`(``url``, ``"PM10"``, days ``=`` ``365``)`` ``guideline_pm10`` ``<-`` ``who_guidelines``$``day``[``who_guidelines``$``metric`` ``==`` ``"PM10"``]`` `[`plot_daily_means`](https://sedzinfo.github.io/golemenviro/reference/plot_daily_means.md)`(``pm10``, ``"PM10"``, ``guideline_pm10``)`

The guideline allows 3 to 4 days above it in a year. To count them over
this year:

[`sum`](https://rdrr.io/r/base/sum.html)`(``pm10``$``value`` ``>`` ``guideline_pm10``)`` ``#> [1] 34`

## Dark mode and saving

Like the charts of [Daily pattern and
comfort](https://sedzinfo.github.io/golemenviro/articles/daily-pattern.html#dark-mode),
[`plot_daily_means()`](https://sedzinfo.github.io/golemenviro/reference/plot_daily_means.md)
takes `mode = "dark"`, which makes the bars and the dashed line lighter
for a dark page. It leaves the background white, so the code is not run
here:

[`plot_daily_means`](https://sedzinfo.github.io/golemenviro/reference/plot_daily_means.md)`(``pm25``, ``"PM2.5"``, ``guideline``, mode ``=`` ``"dark"``)`

The charts are plotly objects, so
[`htmlwidgets::saveWidget()`](https://rdrr.io/pkg/htmlwidgets/man/saveWidget.html)
saves any of them as a web page:

`chart`` ``<-`` `[`plot_daily_means`](https://sedzinfo.github.io/golemenviro/reference/plot_daily_means.md)`(``pm25``, ``"PM2.5"``, ``guideline``)`` ``htmlwidgets``::`[`saveWidget`](https://rdrr.io/pkg/htmlwidgets/man/saveWidget.html)`(``chart``, ``"pm25.html"``)`
