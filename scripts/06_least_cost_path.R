# load packages and locations
source("scripts/02_load_locations.R")

# load DEM
dem <- rast(
  "data/raw/greece_dem.tif"
)

# project DEM to roads crs
dem <- project(
  dem,
  target_crs$wkt
)

# slope raster
slope <- terrain(
  dem,
  v = "slope",
  unit = "radians"
)

# friction surface
friction <- exp(
  3.5 * abs(tan(slope))
)

# convert terra raster -> raster package
friction_raster <- raster::raster(
  friction
)

# transition matrix
tr <- transition(
  friction_raster,
  transitionFunction = function(x) 1 / mean(x),
  directions = 8
)

# geographic correction
tr_corrected <- geoCorrection(
  tr,
  type = "c"
)

# load snapped points
snapped_marathon <- st_read(
  "data/processed/snapped_marathon.gpkg",
)

snapped_athens <- st_read(
  "data/processed/snapped_athens.gpkg",
)

# coordinates
marathon_coords <- st_coordinates(
  snapped_marathon
)

athens_coords <- st_coordinates(
  snapped_athens
)

# least-cost path
path <- shortestPath(
  tr_corrected,
  origin = marathon_coords,
  goal = athens_coords,
  output = "SpatialLines"
)

# convert to sf
path_sf <- st_as_sf(path)

st_crs(path_sf) <- target_crs

# save path
st_write(
  path_sf,
  "data/processed/least_cost_path.gpkg",
  delete_dsn = TRUE
)

# distance
lcp_distance <- st_length(path_sf)

print(
  set_units(
    lcp_distance,
    "km"
  )
)