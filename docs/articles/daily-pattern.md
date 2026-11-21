# Daily pattern and comfort

The Daily Pattern and Comfort tabs of the [golemenviro
app](https://sedzinfo-golemenviro.share.connect.posit.cloud/) draw the
hourly averages of the sensors. In R,
[`get_hourly()`](https://sedzinfo.github.io/golemenviro/reference/get_hourly.md)
downloads them,
[`plot_daily_pattern()`](https://sedzinfo.github.io/golemenviro/reference/plot_daily_pattern.md)
and
[`plot_average_day()`](https://sedzinfo.github.io/golemenviro/reference/plot_average_day.md)
show what repeats every day, and
[`plot_comfort()`](https://sedzinfo.github.io/golemenviro/reference/plot_comfort.md)
and
[`comfort_summary()`](https://sedzinfo.github.io/golemenviro/reference/comfort_summary.md)
how comfortable the room was. [Gauges and time
series](https://sedzinfo.github.io/golemenviro/articles/golemenviro.md)
shows how to install the package and which servers it reads.

[`library`](https://rdrr.io/r/base/library.html)`(`[`golemenviro`](https://sedzinfo.github.io/golemenviro/)`)`` `[`Sys.setenv`](https://rdrr.io/r/base/Sys.setenv.html)`(``TZ ``=`` ``"Europe/Bucharest"``)`` ``url`` ``<-`` ``"http://pip1.crabdance.com:1507/api/v1/query_range"`

The hours are those of the time zone of the R session, here the one of
the app, as [Gauges and time
series](https://sedzinfo.github.io/golemenviro/articles/golemenviro.html#time-zone)
explains. The axis titles name it.

## Download the hourly averages

[`get_hourly()`](https://sedzinfo.github.io/golemenviro/reference/get_hourly.md)
downloads the average of each clock hour of one sensor over the last
`days` days, 30 by default, up to the start of the current hour. It
takes the name of the sensor in Prometheus, such as `"temperature"` or
`"PM25"`, not the name of its column in
[`get_data()`](https://sedzinfo.github.io/golemenviro/reference/get_data.md).
The names of `metric_mid` list them all:

[`names`](https://rdrr.io/r/base/names.html)`(``metric_mid``)`` ``#> [1] "temperature" "humidity" "pressure" "lux" "proximity" "NH3" "reducing" "oxidising" "PM1" "PM25" "PM10"`` ``temperature`` ``<-`` `[`get_hourly`](https://sedzinfo.github.io/golemenviro/reference/get_hourly.md)`(``url``, ``"temperature"``, days ``=`` ``30``)`` `[`head`](https://rdrr.io/r/utils/head.html)`(``temperature``)`` ``#> date hour value`` ``#> 1 2026-10-22 15 29.97733`` ``#> 2 2026-10-22 16 30.02577`` ``#> 3 2026-10-22 17 30.00611`` ``#> 4 2026-10-22 18 29.82130`` ``#> 5 2026-10-22 19 29.37329`` ``#> 6 2026-10-22 20 29.99080`

It has a row per hour: its `date`, its `hour` from 0 to 23 and the
average `value`. When the server cannot be reached,
[`get_hourly()`](https://sedzinfo.github.io/golemenviro/reference/get_hourly.md)
returns `NULL` with a message. When the server has no readings of the
sensor in that time, it returns a data frame without rows. The charts
below take any data frame with these three columns.

## Heatmap

[`plot_daily_pattern()`](https://sedzinfo.github.io/golemenviro/reference/plot_daily_pattern.md)
draws a column per day and a row per hour, midnight at the top, each
colored by the average of that hour. What happens at the same time every
day shows as a horizontal band. `variable` names the sensor in the title
and the hover labels, and `unit` is the unit of the readings:

[`plot_daily_pattern`](https://sedzinfo.github.io/golemenviro/reference/plot_daily_pattern.md)`(``temperature``, ``"Temperature"``, ``degrees_celsius``)`

The colors run from light blue for low values to dark blue for high
ones, the five steps of `blue_steps`. They stop at the 2nd and 98th
percentiles, so that a few spikes do not wash out the rest. Hover over a
cell for its exact value.

`mid` colors one value white, lower values blue and higher values red,
and makes the colors symmetric around it. `metric_mid` holds the values
the app uses: room temperature, the middle of the comfortable humidity,
the standard air pressure at sea level, and for PM2.5 and PM10 the
guidelines of the World Health Organization for a day. It is `NA` for
the sensors with no such value, which keep the blue scale:

`metric_mid`` ``#> temperature humidity pressure lux proximity NH3 reducing oxidising PM1 PM25 PM10 `` ``#> 24.00 50.00 1013.25 NA NA NA NA NA NA 15.00 45.00`` `[`plot_daily_pattern`](https://sedzinfo.github.io/golemenviro/reference/plot_daily_pattern.md)`(``temperature``, ``"Temperature"``, ``degrees_celsius``,`` `` mid ``=`` ``metric_mid``[[``"temperature"``]``]``)`

`red_steps` has five reds with the same lightness as the blues, for
color scales of your own where higher means hotter or worse.

## A typical day

[`plot_average_day()`](https://sedzinfo.github.io/golemenviro/reference/plot_average_day.md)
sums up the same hourly averages in one day. For each hour it draws the
median over all the days (the line) and the middle half of the days,
between the 25th and 75th percentiles (the band). A narrow band means
that hour is much the same every day:

[`plot_average_day`](https://sedzinfo.github.io/golemenviro/reference/plot_average_day.md)`(``temperature``, ``"Temperature"``, ``degrees_celsius``)`

## Comfort

[`plot_comfort()`](https://sedzinfo.github.io/golemenviro/reference/plot_comfort.md)
takes the hourly averages of temperature and humidity and draws a point
for every hour that has both, at its temperature and humidity. The
points are colored by the hour of the day: blue at night, orange in the
morning, yellow at midday and red in the evening. The green box is the
comfort zone, 20 to 25 °C and 40 to 60% humidity, and the title says how
many of the hours were inside it. The corners name what lies that way:

`humidity`` ``<-`` `[`get_hourly`](https://sedzinfo.github.io/golemenviro/reference/get_hourly.md)`(``url``, ``"humidity"``, days ``=`` ``30``)`` `[`plot_comfort`](https://sedzinfo.github.io/golemenviro/reference/plot_comfort.md)`(``temperature``, ``humidity``)`

[`comfort_summary()`](https://sedzinfo.github.io/golemenviro/reference/comfort_summary.md)
gives the numbers: how many hours had both readings, and the percentages
of them that were comfortable, too warm, too cool, too dry and too
humid. An hour can be both too warm and too dry:

[`str`](https://rdrr.io/r/utils/str.html)`(`[`comfort_summary`](https://sedzinfo.github.io/golemenviro/reference/comfort_summary.md)`(``temperature``, ``humidity``)``)`` ``#> List of 6`` ``#> $ hours : int 720`` ``#> $ comfortable: num 1.94`` ``#> $ too_warm : num 89.7`` ``#> $ too_cool : num 0`` ``#> $ too_dry : num 25.6`` ``#> $ too_humid : num 0`

Both functions take other comfortable ranges with `temperature_range`
and `humidity_range`.

## Dark mode

[`plot_daily_pattern()`](https://sedzinfo.github.io/golemenviro/reference/plot_daily_pattern.md),
[`plot_average_day()`](https://sedzinfo.github.io/golemenviro/reference/plot_average_day.md)
and
[`plot_comfort()`](https://sedzinfo.github.io/golemenviro/reference/plot_comfort.md)
take `mode = "dark"` for a page with a dark background. It changes the
colors that the functions choose. Without `mid`, the blue scale of the
heatmap runs the other way, so that low values fade into the dark page
and high values stand out. The lines, bands, points and labels are
lighter.

The background stays white and the text of the axes dark: the app
darkens them with its stylesheet. On a page of your own, set them with
`plotly::layout()`. On this light page the dark colors would not read
well, so the code is not run here:

[`plot_comfort`](https://sedzinfo.github.io/golemenviro/reference/plot_comfort.md)`(``temperature``, ``humidity``, mode ``=`` ``"dark"``)`` ``|>`` `` ``plotly``::``layout``(`` `` paper_bgcolor ``=`` ``"#222222"``, plot_bgcolor ``=`` ``"#222222"``,`` `` font ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(``color ``=`` ``"#dddddd"``)`` `` ``)`

The charts are plotly objects, so
[`htmlwidgets::saveWidget()`](https://rdrr.io/pkg/htmlwidgets/man/saveWidget.html)
saves any of them as a web page, as [Gauges and time
series](https://sedzinfo.github.io/golemenviro/articles/golemenviro.html#save-or-change-a-chart)
shows.
