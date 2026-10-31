# Launch the ShinyApp (Do not remove this comment)
# To deploy, run: rsconnect::deployApp()
# Or use the blue button on top of this file
# Note that you'll need to upload the whole package to ShinyApps.io

# RStudio's "Run App" button launches this file in a separate R process that
# inherits RSTUDIO=1 from the parent session but isn't connected to the
# RStudio API. cli (used by pkgload) sees RSTUDIO=1 and tries to query the
# RStudio theme via rstudioapi, which throws "RStudio not running" because
# that connection doesn't actually exist here. Clearing the var makes cli
# skip that probe. Harmless for Ctrl+Enter, sourcing, or shinyapps.io, where
# RSTUDIO isn't set (or the mismatch doesn't occur) anyway.
Sys.unsetenv("RSTUDIO")

pkgload::load_all(export_all = FALSE, helpers = FALSE, attach_testthat = FALSE)
options("golem.app.prod" = TRUE)
pimoroni(
  prometheus_url = c(
    "http://pip1.crabdance.com:1507/api/v1/query_range",
    "http://pip1.crabdance.com:1505/api/v1/query_range"
  ),
  analytics = TRUE
)


# rsconnect::writeManifest(appDir = ".", appPrimaryDoc = "app.R")