##########################################################################################
# DIRECTORIES
##########################################################################################
# R CMD check golemenviro
# R CMD Rd2pdf golemenviro
# R CMD build golemenviro --resave-data
library(devtools)
library(roxygen2)
rm(list = ls())
graphics.off()
cat("\014")
##########################################################################################
# FUNCTIONS PACKAGE
##########################################################################################
directory <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(directory)
# usethis::create_package("golemenviro")
if ("golemenviro" %in% loadedNamespaces()) unloadNamespace("golemenviro") # an old version still loaded would make the reinstalled one look corrupt
if ("golemenviro" %in% rownames(installed.packages())) remove.packages("golemenviro")
document()
install()
library(golemenviro)

pkgdown::build_site(getwd(), lazy = TRUE)
system("R CMD Rd2pdf . --force --no-preview --output=golemenviro.pdf")
if (.Platform$OS.type == "windows") shell.exec("golemenviro.pdf") else system("evince golemenviro.pdf")
system("R CMD build . --resave-data")

pimoroni(prometheus_url=c("http://pip1.crabdance.com:1507/api/v1/query_range",
                          "http://pip1.crabdance.com:1505/api/v1/query_range"))


