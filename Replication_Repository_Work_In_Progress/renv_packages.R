# Run from repository root in R 4.3+.
install.packages(c(
  "haven", "dplyr", "readr", "tidyr", "purrr", "ggplot2",
  "fixest", "broom", "marginaleffects"
))
# For a fully pinned environment after successful installation:
# install.packages("renv")
# renv::init()
# renv::snapshot()
