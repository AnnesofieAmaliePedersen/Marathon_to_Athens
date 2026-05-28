# load packages
source("scripts/01_load_packages.R")

# load roads to inherit crs
roads_reference <- st_read(
  "data/raw/itinere_roads.geojson",
)

# use roads crs directly
target_crs <- st_crs(roads_reference)

# create Marathon point
marathon <- tibble(
  place = "Marathon",
  lon = 23.9619,
  lat = 38.1507
) |>
  st_as_sf(
    coords = c("lon", "lat"),
    crs = 4326
  ) |>
  st_transform(target_crs)

# create Athens point
athens <- tibble(
  place = "Athens",
  lon = 23.7275,
  lat = 37.9838
) |>
  st_as_sf(
    coords = c("lon", "lat"),
    crs = 4326
  ) |>
  st_transform(target_crs)