# load packages and locations
source("scripts/02_load_locations.R")

# calculate euclidean distance (meter)
euclidean_distance <- st_distance(
  marathon,
  athens
)

# convert distance to km
euclidean_distance_km <- set_units(
  euclidean_distance,
  "km"
)

print(euclidean_distance_km)