# load packages
source("scripts/01_load_packages.R")

# create output folder
dir.create(
  "outputs/tables",
  recursive = TRUE,
)

# load DEM
greece_dem <- rast(
  "data/raw/greece_dem.tif"
)

# load routes
ancient_route <- st_read(
  "data/processed/ancient_route.gpkg",
)

least_cost <- st_read(
  "data/processed/least_cost_path.gpkg",
)

# load snapped points
snapped_marathon <- st_read(
  "data/processed/snapped_marathon.gpkg",
)

snapped_athens <- st_read(
  "data/processed/snapped_athens.gpkg",
)

# inherit crs directly from routes
analysis_crs <- st_crs(
  ancient_route
)

# project DEM to same crs
greece_dem <- project(
  greece_dem,
  analysis_crs$wkt
)

# create euclidean route
euclidean_route <- st_union(
  snapped_marathon,
  snapped_athens
) |>
  st_cast("LINESTRING") |>
  st_as_sf()

# create function to sample route points
sample_route_points <- function(
    route,
    spacing = 100
) {
  
  # extract geometry
  geom <- st_geometry(route)
  
  # merge geometry
  geom <- st_union(geom)
  
  # geometry type
  geom_type <- as.character(
    st_geometry_type(geom)
  )
  
  # merge if MULTILINESTRING
  if (geom_type == "MULTILINESTRING") {
    
    geom <- st_line_merge(geom)
  }
  
  # check geometry again
  geom_type <- as.character(
    st_geometry_type(geom)
  )
  
  # if still MULTILINESTRING
  if (geom_type == "MULTILINESTRING") {
    
    geom <- st_cast(
      geom,
      "LINESTRING"
    )
    
    geom <- geom[1]
  }
  
  # route length
  route_length <- as.numeric(
    st_length(geom)
  )[1]
  
  # sample distances
  sample_distances <- seq(
    from = 0,
    to = route_length,
    by = spacing
  )
  
  # sample fractions
  sample_fraction <- sample_distances /
    route_length
  
  # sample points
  sampled_points <- st_line_sample(
    geom,
    sample = sample_fraction
  )
  
  # convert to sf
  sampled_points <- st_cast(
    sampled_points,
    "POINT"
  ) |>
    st_as_sf()
  
  return(sampled_points)
}

# create function for elevation metrics
calculate_elevation_metrics <- function(
    route,
    dem
) {
  
  # sample route
  points <- sample_route_points(
    route,
    spacing = 100
  )
  
  # extract elevations
  elevations <- terra::extract(
    dem,
    vect(points)
  )[,2]
  
  # remove NA
  elevations <- elevations[
    !is.na(elevations)
  ]
  
  # elevation difference
  elev_diff <- diff(elevations)
  
  # total gain
  gain <- sum(
    elev_diff[elev_diff > 0],
    na.rm = TRUE
  )
  
  # total loss
  loss <- abs(
    sum(
      elev_diff[elev_diff < 0],
      na.rm = TRUE
    )
  )
  
  return(
    list(
      gain = gain,
      loss = loss
    )
  )
}

# create function for running time with Toblers hiking function
calculate_tobler_time <- function(
    route,
    dem,
    spacing = 100
) {
  
  # sample route
  points <- sample_route_points(
    route,
    spacing = spacing
  )
  
  # elevations
  elevations <- terra::extract(
    dem,
    vect(points)
  )[,2]
  
  # remove invalid
  valid <- !is.na(elevations)
  
  elevations <- elevations[valid]
  
  points <- points[valid, ]
  
  # coordinates
  coords <- st_coordinates(points)
  
  # horizontal distances
  dx <- diff(coords[,1])
  dy <- diff(coords[,2])
  
  horizontal_distance <- sqrt(
    dx^2 + dy^2
  )
  
  # elevation change
  dz <- diff(elevations)
  
  # slope
  slope <- dz / horizontal_distance
  
  # Tobler hiking function
  speed <- 6 * exp(
    -3.5 * abs(slope + 0.05)
  )
  
  # convert hiking -> running
  speed <- speed * (10 / 6)
  
  # segment times
  segment_time <- (
    horizontal_distance / 1000
  ) / speed
  
  # total time
  total_time <- sum(
    segment_time,
    na.rm = TRUE
  )
  
  return(total_time)
}

# distance calculations
euclidean_distance <- as.numeric(
  st_length(
    st_union(euclidean_route)
  )
) / 1000

ancient_distance <- as.numeric(
  st_length(
    st_union(ancient_route)
  )
) / 1000

leastcost_distance <- as.numeric(
  st_length(
    st_union(least_cost)
  )
) / 1000

# elevation calculations
euclidean_elev <- calculate_elevation_metrics(
  euclidean_route,
  greece_dem
)

ancient_elev <- calculate_elevation_metrics(
  ancient_route,
  greece_dem
)

leastcost_elev <- calculate_elevation_metrics(
  least_cost,
  greece_dem
)

# Tobler running times
euclidean_time <- calculate_tobler_time(
  euclidean_route,
  greece_dem
)

ancient_time <- calculate_tobler_time(
  ancient_route,
  greece_dem
)

leastcost_time <- calculate_tobler_time(
  least_cost,
  greece_dem
)

# results
travel_times <- tibble(
  
  model = c(
    "Euclidean",
    "Ancient network",
    "Least-cost"
  ),
  
  distance_km = c(
    euclidean_distance,
    ancient_distance,
    leastcost_distance
  ),
  
  elevation_gain_m = c(
    euclidean_elev$gain,
    ancient_elev$gain,
    leastcost_elev$gain
  ),
  
  elevation_loss_m = c(
    euclidean_elev$loss,
    ancient_elev$loss,
    leastcost_elev$loss
  ),
  
  estimated_running_time_h = c(
    euclidean_time,
    ancient_time,
    leastcost_time
  )
)

# round values
travel_times <- travel_times |>
  mutate(
    across(
      where(is.numeric),
      \(x) round(x, 1)
    )
  )

# print table
print(
  travel_times,
  width = Inf
)

# save table
write_csv(
  travel_times,
  "outputs/tables/travel_times.csv"
)