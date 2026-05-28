# load packages
source("scripts/01_load_packages.R")

# create output folder
dir.create(
  "outputs/map",
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

# inherit crs from route data
target_crs <- st_crs(
  ancient_route
)

# ensure DEM matches crs
greece_dem <- project(
  greece_dem,
  target_crs$wkt
)

# create euclidean route
euclidean_geom <- st_sfc(
  st_cast(
    st_union(
      st_geometry(snapped_marathon),
      st_geometry(snapped_athens)
    ),
    "LINESTRING"
  ),
  crs = target_crs
)

euclidean_route <- st_sf(
  route = "Euclidean",
  geometry = euclidean_geom
)

# create hillshade
slope <- terrain(
  greece_dem,
  v = "slope",
  unit = "radians"
)

aspect <- terrain(
  greece_dem,
  v = "aspect",
  unit = "radians"
)

hillshade <- shade(
  slope,
  aspect,
  angle = 40,
  direction = 315
)

# hillshade dataframe
hillshade_df <- as.data.frame(
  hillshade,
  xy = TRUE
)

colnames(hillshade_df) <- c(
  "x",
  "y",
  "shade"
)

# DEM dataframe
dem_df <- as.data.frame(
  greece_dem,
  xy = TRUE
)

colnames(dem_df) <- c(
  "x",
  "y",
  "elevation"
)

# create map with ggplot
route_map <- ggplot() +
  
  # DEM
  geom_raster(
    data = dem_df,
    aes(
      x = x,
      y = y,
      fill = elevation
    )
  ) +
  
  # hillshade
  geom_raster(
    data = hillshade_df,
    aes(
      x = x,
      y = y,
      alpha = shade
    ),
    fill = "black"
  ) +
  
  # hillshade transparency
  scale_alpha(
    range = c(0, 0.45),
    guide = "none"
  ) +
  
  # elevation colours
  scale_fill_gradientn(
    colours = c(
      "#9ecf6b",
      "#c8dd8f",
      "#d8c8a8",
      "#c2aa84",
      "#a98763",
      "#8a6f4d",
      "#6e563e"
    ),
    name = "Elevation (m)"
  ) +
  
  # euclidean route
  geom_sf(
    data = euclidean_route,
    aes(
      colour = "Euclidean Route"
    ),
    linewidth = 1,
    linetype = "dashed"
  ) +
  
  # ancient route
  geom_sf(
    data = ancient_route,
    aes(
      colour = "Ancient Route"
    ),
    linewidth = 1
  ) +
  
  # least-cost route
  geom_sf(
    data = least_cost,
    aes(
      colour = "Least-cost Route"
    ),
    linewidth = 1
  ) +
  
  # route colours
  scale_colour_manual(
    name = "Routes",
    values = c(
      "Ancient Route" = "#ff8fa3",
      "Least-cost Route" = "#8ecae6",
      "Euclidean Route" = "black"
    )
  ) +
  
  # Marathon point
  geom_sf(
    data = snapped_marathon,
    colour = "black",
    fill = "red",
    shape = 21,
    size = 3,
    stroke = 1
  ) +
  
  # Athens point
  geom_sf(
    data = snapped_athens,
    colour = "black",
    fill = "red",
    shape = 21,
    size = 3,
    stroke = 1
  ) +
  
  # Marathon label
  geom_sf_text(
    data = snapped_marathon,
    aes(label = "Marathon"),
    nudge_y = 2500,
    size = 5
  ) +
  
  # Athens label
  geom_sf_text(
    data = snapped_athens,
    aes(label = "Athens"),
    nudge_y = -2500,
    size = 5
  ) +
  
  # preserve projected crs
  coord_sf() +
  
  # style
  theme_minimal() +
  
  theme(
    legend.position = "right",
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    plot.title = element_text(
      size = 20,
      face = "bold"
    )
  ) +
  
  labs(
    title = "Route Comparison: Marathon to Athens"
  )

# print map
print(route_map)

# save map
ggsave(
  filename = "outputs/map/route_comparison.png",
  plot = route_map,
  width = 12,
  height = 10,
  dpi = 300
)