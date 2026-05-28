# load packages and locations
source("scripts/01_load_packages.R")
source("scripts/02_load_locations.R")

# load roads
roads <- st_read(
  "data/raw/itinere_roads.geojson"
)

# remove Z dimension
roads <- st_zm(roads)

# ensure valid geometries
roads <- st_make_valid(roads)

# create study area
study_area <- st_union(
  marathon,
  athens
) |>
  st_buffer(80000)

# clip roads to study area
roads <- st_intersection(
  roads,
  study_area
)

# explode geometries
roads <- st_cast(
  roads,
  "MULTILINESTRING",
)

roads <- st_cast(
  roads,
  "LINESTRING",
)

# remove empty geometries
roads <- roads[
  !st_is_empty(roads),
]

# keep only LINESTRING
roads <- roads[
  st_geometry_type(roads) == "LINESTRING",
]

# remove invalid geometries again
roads <- st_make_valid(roads)

# create sfnetwork
network <- as_sfnetwork(
  roads,
  directed = FALSE
)

# save network
saveRDS(
  network,
  "data/processed/ancient_network.rds"
)