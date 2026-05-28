# load packages and locations
source("scripts/02_load_locations.R")

# load network
network <- readRDS(
  "data/processed/ancient_network.rds"
)

# add edge lengths
network <- network |>
  activate(edges) |>
  mutate(length = edge_length())

# get nodes
nodes <- network |>
  activate(nodes) |>
  st_as_sf()

# nearest nodes
start_node <- st_nearest_feature(
  marathon,
  nodes
)

end_node <- st_nearest_feature(
  athens,
  nodes
)

# snapped points
snapped_marathon <- nodes[start_node, ]
snapped_athens <- nodes[end_node, ]

snapped_marathon$place <- "Snapped Marathon"
snapped_athens$place <- "Snapped Athens"

# save snapped points
st_write(
  snapped_marathon,
  "data/processed/snapped_marathon.gpkg",
  delete_dsn = TRUE
)

st_write(
  snapped_athens,
  "data/processed/snapped_athens.gpkg",
  delete_dsn = TRUE
)

# shortest path
route <- st_network_paths(
  network,
  from = start_node,
  to = end_node,
  weights = "length"
)

# extract route
route_edges <- network |>
  activate(edges) |>
  slice(route$edge_paths[[1]]) |>
  st_as_sf()

# save route
st_write(
  route_edges,
  "data/processed/ancient_route.gpkg",
  delete_dsn = TRUE
)

# route distance
route_distance <- sum(route_edges$length)

print(
  set_units(
    route_distance,
    "km"
  )
)