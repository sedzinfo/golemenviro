This app shows the readings of Pimoroni Enviro and Enviro+ sensor boards on a Raspberry Pi, as their Prometheus servers keep them. Each server in the Server box at the top of a tab is one device. Times are in {{timezone}}.

**On this page:** [Current](#about-current) · [Time Series](#about-timeseries) · [Daily Pattern](#about-pattern) · [Air Quality](#about-airquality) · [The sensors](#about-sensors) · [Data](#about-data)

<h3 id="about-current">Current</h3>

A gauge per sensor with its last reading. **Last reading** above them says when it was taken; it turns red when it is more than 30 minutes old, as the device may have stopped sending. The gauges are updated every 5 minutes while the page is open.

- The **big number** is the last reading. The small one under it is its difference from the reference point, the thin line across the gauge.
- The **green band** is a comfortable or recommended range: 20–25 °C, 40–60% humidity, 1,010–1,015 hPa and 1,000–1,500 lux. For particles it is the 24-hour guideline of the World Health Organization (2021): up to 15 µg/m³ for PM2.5, and for PM1, which has no guideline of its own, and up to 45 µg/m³ for PM10. The guidelines are for 24-hour averages, so a single reading above them, such as while cooking, is not yet a breach; the Air Quality tab compares the averages of whole days with them.
- **Proximity and the three gases** have no fixed scale: their gauges cover the last 7 days, from the lowest reading minus one standard deviation to the highest plus one. The green band is the mean ± one standard deviation and the reference point is the mean, so a reading in the band is usual for that device and one outside it is not.

<h3 id="about-timeseries">Time Series</h3>

A chart of the sensor you pick over the period you pick, with about 1,000 points: for 1 week a point every 10 minutes. The readings of all the sensors are downloaded together, so picking another sensor draws it straight away. Up to 1 month, each point is the reading at that moment; from 3 months on, the points are 2 or more hours apart and each is the average of the readings in its step, so short spikes are averaged away.

- **Smoothing** is the mean of 30 points centred on each point: about 5 hours for 1 week, 11 days for 1 year.
- **Mean** is the mean of the whole period.
- The **summary** on the right gives the last reading, the mean (μ), the minimum and maximum, the standard deviation (σ), how far readings typically are from the mean, the range (maximum − minimum), and the first and last day.
- The button at the bottom right of the chart shows it full screen.

<h3 id="about-pattern">Daily Pattern</h3>

What repeats every day, for one sensor over the period you pick.

- The **heatmap** has a column per day and a row per hour, midnight at the top. Each cell is the average of the readings in that hour: darker for higher values on a light page, brighter on a dark one. Habits show as horizontal bands, such as the heating coming on at the same hour, humidity after a morning shower, or particles when someone cooks; a change from one column to the next shows when a pattern started or stopped. The colors stop at the 2nd and 98th percentiles of the period, so that a few spikes do not wash out the rest; hover over a cell for its exact value.
- **A typical day**, under it, gives for each hour the median of that hour over all the days (the line) and the middle half of the days, between the 25th and 75th percentiles (the band). A narrow band means that hour is much the same every day; a wide one, that it varies.
- The button at the bottom right of each chart shows it full screen.

The hours are in {{timezone}}. On the days the clocks change, one hour is missing or holds the average of two.

<h3 id="about-airquality">Air Quality</h3>

How the particles compare with the air quality guidelines of the World Health Organization (2021), which are set for the averages of whole days and years, not for single readings.

- Each **bar** is the average of one day, midnight to midnight, of PM2.5 or PM10, and the dashed line is the guideline for a day: 15 µg/m³ for PM2.5 and 45 µg/m³ for PM10. A day counts only when the device sent readings in at least 18 of its hours (75%), as in the usual rules for daily averages; today, still running, is left out.
- The **big number** above each chart counts the days above that guideline. The guideline is the 99th percentile of the days of a year, so it allows 3 to 4 such days in a year.
- The **average of the period** is set against the guideline for a year: 5 µg/m³ for PM2.5 and 15 µg/m³ for PM10. That guideline is for the average of a whole year, so for a shorter period it is only a pointer, as winters and summers differ.
- The guidelines are written for the air outdoors. Indoors they are the usual yardstick too, and cooking, candles and smoke raise the particles there.
- PM1 has no guideline and is left out. A device without a particle sensor sends readings that never change, and the tab says so.
- The button at the bottom right of each chart shows it full screen.

<h3 id="about-sensors">The sensors</h3>

| Sensor | What it measures | Unit |
|---|---|---|
| Temperature | The temperature of the air at the board (BME280) | °C |
| Humidity | The relative humidity (BME280) | % |
| Pressure | The air pressure where the device is (BME280) | hPa |
| Lux | The light that reaches the sensor (LTR-559) | lux |
| Proximity | The infrared light reflected back by something close to the sensor (LTR-559): higher is closer | none |
| Reducing, Oxidising, NH3 | The resistance of the three channels of the gas sensor (MiCS-6814), Enviro+ only | Ohms |
| PM1, PM2.5, PM10 | The mass of the particles smaller than 1, 2.5 and 10 micrometres in a cubic metre of air (PMS5003), Enviro+ with the particulate sensor only | µg/m³ |

Some of these numbers need more than a unit:

- **Temperature**: on an Enviro+ the sensor sits close to the Raspberry Pi, whose heat makes it read high. The exporter corrects for it when started with `--factor`, by taking off a share of the difference between the temperature of the processor and that of the sensor. As humidity is relative to temperature, a sensor warmer than the room also reads the humidity low.
- **Pressure** is measured where the device is, not reduced to sea level as in weather reports, so it reads about 12 hPa lower for every 100 metres of altitude. The green band of its gauge, around 1,013 hPa, is the average at sea level.
- **The gases are not concentrations.** The gas sensor has three metal-oxide channels whose resistance changes with the gases around them. The resistance of the reducing channel (mostly carbon monoxide, also hydrogen, ethanol and hydrocarbons) and of the NH3 channel (mostly ammonia) **drops** when there is more of their gases; that of the oxidising channel (mostly nitrogen dioxide) **rises**. The values also drift with temperature, humidity and the age of the sensor, and need some time to settle after the device starts, so compare a channel with its own recent readings, as the gauges do, not with another device or with a fixed number.
- **Particles**: PM10 includes PM2.5, which includes PM1, so PM10 is at least PM2.5, and PM2.5 at least PM1. The World Health Organization's guidelines are 15 µg/m³ for PM2.5 and 45 µg/m³ for PM10 as 24-hour averages, and 5 and 15 µg/m³ as yearly averages.
- **Lux** depends on where the device faces: indoor lighting gives a few hundred lux, daylight through a window thousands.

<h3 id="about-data">Data</h3>

- Each device runs [enviroplus_exporter](https://github.com/tijmenvandenbrink/enviroplus_exporter), which reads the sensors, and a Prometheus server that collects and keeps the readings. The app asks the server you pick for the readings of the period shown.
- An Enviro, unlike the Enviro+, has no gas or particle sensors; its exporter then sends values that never change, and the app leaves those sensors out.
- When a server cannot be reached, its gauges and charts say so instead of showing an error.
