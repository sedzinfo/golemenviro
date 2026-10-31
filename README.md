# Data Visualization for Enviro Using Prometheus
Displays data of Pimoroni Enviro from Prometheus

Live app: https://sedzinfo-golemenviro.share.connect.posit.cloud/  
Documentation: https://sedzinfo.github.io/golemenviro/  

![Alt text](https://github.com/sedzinfo/golemenviro/raw/main/screenshots/pimoroni_front.png)
![Alt text](https://github.com/sedzinfo/golemenviro/raw/main/screenshots/pimoroni_back.png)

## Examples of how to set up your own Pimoroni Enviro
[Getting Started with Enviro Plus](https://learn.pimoroni.com/article/getting-started-with-enviro-plus)  
[Enviro Plus Python GitHub Repository](https://github.com/pimoroni/enviroplus-python)  

In order to create your own server you need to: 
1. Install the Pimoroni drivers on the Pi  
2. Install [enviroplus_exporter](https://github.com/tijmenvandenbrink/enviroplus_exporter) on the Pi; it exports the readings under the metric names the app reads (temperature, humidity, pressure, lux, proximity, NH3, reducing, oxidising, PM1, PM25, PM10). On an Enviro (not Enviro+), start it with `--enviro=true`, as it has no gas or particulate sensors  
3. Deploy a Prometheus server on the Pi that scrapes the exporter  
4. After you deploy the server use the url as an argument in prometheus_url (see below)  

# Installation Instructions
## install R
installation instructions can be found here: https://cran.r-project.org/  
## install RStudio IDE (optional but a good idea)  
installation instructions can be found here: https://posit.co/downloads/  

open RStudio and type in the console:
```
install.packages("devtools")
library(devtools)
install_github("sedzinfo/golemenviro")
```

# Usage
```
library(golemenviro)
```

substitute the url from your prometheus server  
```
pimoroni(prometheus_url=c("http://pip1.crabdance.com:1507/api/v1/query_range","http://pip1.crabdance.com:1505/api/v1/query_range"))
```

When a server cannot be reached, its gauges and charts say so instead of showing an error, and `get_data()` returns `NULL` with a message.

# Tabs
- **Current**: a gauge per sensor with its last reading, updated every 5 minutes
- **Time Series**: a chart of one sensor, picked as in the Daily Pattern tab, over a period from 6 hours to 1 year, with a moving average and a summary
- **Daily Pattern**: the hourly averages of one sensor as a heatmap, a column per day and a row per hour, so that what repeats every day shows as bands, and a typical day: the median of each hour and the range of its middle half
- **Air Quality**: the daily averages of PM2.5 and PM10 against the guidelines of the World Health Organization, with the number of days above them and the average of the period
- **About**: what each tab shows, what the sensors measure and how to read their numbers, such as the gas readings, which are resistances rather than concentrations. The text is in `inst/app/about.md`

# Screenshots
![Alt text](https://github.com/sedzinfo/golemenviro/raw/main/screenshots/enviro1.png)
![Alt text](https://github.com/sedzinfo/golemenviro/raw/main/screenshots/enviro2.png)

# Development

Run the tests with `devtools::test()`, and the full package check with `devtools::check()`.

## Deploying to Posit Connect Cloud

The live app runs on Posit Connect Cloud, which deploys it from this GitHub repository using `manifest.json`. `app.R` starts the app with the two servers above; change them there for your own. It also sets `analytics = TRUE`, which adds the cookie banner of the sedzinfo.github.io sites and, once a visitor accepts, Google Analytics; `pimoroni()` leaves them out unless asked, so running the app yourself sends nothing. Whenever you add or remove files or change the packages the app uses, regenerate `manifest.json` from the package folder with `rsconnect::writeManifest(appDir = ".", appPrimaryDoc = "app.R")` (the command is commented at the bottom of `app.R`) and push it with the other changes. `.rscignore` keeps the manifest to the files the app needs.

---

![Stars](https://img.shields.io/github/stars/sedzinfo/golemenviro)
![Watchers](https://img.shields.io/github/watchers/sedzinfo/golemenviro)
![Repo Size](https://img.shields.io/github/repo-size/sedzinfo/golemenviro)
![Open Issues](https://img.shields.io/github/issues/sedzinfo/golemenviro)
![Forks](https://img.shields.io/github/forks/sedzinfo/golemenviro)
![Last Commit](https://img.shields.io/github/last-commit/sedzinfo/golemenviro)
![Contributors](https://img.shields.io/github/contributors/sedzinfo/golemenviro)
![License](https://img.shields.io/github/license/sedzinfo/golemenviro)
![Workflow Status](https://img.shields.io/github/actions/workflow/status/sedzinfo/golemenviro/build-tarball.yml)
![R-CMD-check](https://github.com/sedzinfo/golemenviro/actions/workflows/R-CMD-check.yaml/badge.svg)
