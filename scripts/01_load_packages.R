# load dependencies
packages <- c(
  "sf",
  "sfnetworks",
  "tidyverse",
  "tidygraph",
  "terra",
  "gdistance",
  "units",
  "tmap",
  "mapview"
)

install.packages(packages)

lapply(
  packages,
  library,
  character.only = TRUE
)