# Route Modelling and Spatial Analysis for Marathon to Athens

This repository contains code used for investigating possible travel routes between Marathon and Athens in ancient Greece using spatial network analysis and least-cost path modeling in R.

The project compares the euclidean route, Ancient road network route and least-cost route to explore how terrain and historical infrastructure may have influenced movement and travel efficiency.

## Repository Structure
```
data/
├── raw/            # raw input datasets
├── processed/      # processed spatial data

outputs/
├── map/            # final map output
├── tables/         # final table output

README/
├── LICENSE         # MIT license
├── README.md       # documentation

scripts/
├── 01_load_packages.R        # install and load dependencies
├── 02_load_locations.R       # define Marathon and Athens locations   
├── 03_create_network.R       # preprocces ancient road network
├── 04_euclidean_distance.R   # calculate euclidean distance
├── 05_network_route.R        # generate shortest route on ancient road network
├── 06_least_cost_path.R      # create terrain based least-cost path
├── 07_route_analysis.R       # compare route distance, elevation and estimated running time
├── 08_visualisation.R        # create map visualisation
```

## Reproduce the project
### Software dependencies
The project was developed and tested in the UCloud environment running Ubuntu 24.04.4 LTS using R version 4.5.3 and RStudio version 2026.1.1.403. 
The spatial analysis workflow was implemented using the packages:
```
sf (1.0-21)
sfnetworks (0.6.6)
terra (1.9-27)
gdistance (1.6.5)
raster (3.6-32)
tidyverse (2.0.0)
tidygraph (1.3.1)
units (1.0-1)
tmap (4.3)
mapview (2.11.4)
```

Additional Linux system dependencies were required to compile and run spatial packages correctly within the UCloud environment. These included GDAL, GEOS, PROJ, and UDUNITS2 libraries installed through apt. The following commands were used to ensure compatibility and successful installation of spatial packages through the terminal in R:
```
sudo apt update

sudo apt purge -y \
  libmariadb-dev \
  libmariadb-dev-compat \
  mariadb-common

sudo apt autoremove -y

sudo apt --fix-broken install

sudo apt install -y --no-install-recommends \
  libgdal-dev \
  libgeos-dev \
  libproj-dev \
  libudunits2-dev \
  gdal-bin \
  proj-bin
```

### Clone repository
Copy following code and enter in terminal
```
git clone https://github.com/AnnesofieAmaliePedersen/Marathon_to_Athens.git
cd Marathon_to_Athens
```

### Data Sources
Ancient road network dataset (European Space Agency (2024). Copernicus Global Digital Elevation Model. Distributed by OpenTopography. https://doi.org/10.5069/G9028PQB):
From following site: https://zenodo.org/records/17122148 please:
```
Download the `itinere_roads.geojson` dataset version 1.3
Save it as:
`data/raw/itinere_roads.geojson`
```


Digital Elevation Model (DEM) of Greece (de Soto, P., Pažout, A., Brughmans, T., Vahlstrup, P., Auir, A., Bongers, T., Christoffersen, J., Crépy, M., Johansen, M. H., Lewis, J., MANIERE, L., Massa, M., Møller, L. M. H., Redon, B., Renda, G., Şahin, H., Sobotkova, A., Spatzek, A. L., Verhagen, P., & Weissova, B. (2025). A High-Resolution Dataset of Roads of the Roman Empire: Itiner-e static version 2024 (1.3) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.17122148):
The DEM used in this project was manually downloaded from the OpenTopography portal using the Copernicus GLO-30 Global Digital Elevation Model (30 m resolution).
From the following site: https://portal.opentopography.org/raster?opentopoID=OTSDEM.032021.4326.3 reproduce the DEM extraction by:
```
Opening the OpenTopography Copernicus GLO-30 interface.
Selecting output format: GeoTIFF.
Manually entering the following bounding coordinates:
xmin = 23.712615970987
ymin = 37.953131615314
xmax = 24.043304430786
ymax = 38.190110645247
Downloading the DEM and saving it as:
data/raw/greece_dem.tif
```
The downloaded DEM is provided in EPSG:4326 geographic coordinates and is reprojected during analysis to match the projected CRS of the historical road network.

## Run analyses
In the console run scripts in following order:
```
source("scripts/01_load_packages.R")
source("scripts/02_load_locations.R")
source("scripts/03_prepare_ancient_network.R")
source("scripts/04_euclidean_distance.R")
source("scripts/05_network_route.R")
source("scripts/06_least_cost_path.R")
source("scripts/07_travel_time_estimation.R")
source("scripts/08_visualisation.R")
```

## License
This project is licensed under the MIT License: see the LICENSE file for details.

## Contact
For further questions, please contact one of the following emails:
smilladh@gmail.com
pedersen.annesofie@gmail.com