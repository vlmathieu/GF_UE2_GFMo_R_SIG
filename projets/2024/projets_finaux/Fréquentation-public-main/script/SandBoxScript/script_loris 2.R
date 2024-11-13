install.packages("readxl")
install.packages("openxlsx2")
install.packages("happign")
install.packages("httr2")
install.packages("tmap")
install.packages("ggmap")

install.packages("remotes")            # Si remotes n'est pas encore installé
options(download.file.method = "curl") # pour contourner le délai maximum de 60 secondes

remotes::install_gitlab(repo = 'metric-osrm/metric-osrm-package',   
                        host = 'git.lab.sspcloud.fr')  
  
options(osrm.server = "https://metric-osrm-backend.lab.sspcloud.fr/") # éxécuter à chaque utilisation
options(osrm.profile = "driving")                                     # éxécuter à chaque utilisation

install.packages("ggspatial")
install.packages("mapview")
install.packages("osmdata")
install.packages("sf")
install.packages("data.table")
install.packages("devtools")
install.packages("tmap")
install.packages("mapedit")
install.packages("spdep")



library(tmap)
library(osmdata)
library(sf)

# Obtention des points de la forêt
point_foret <- mapedit::drawFeatures()
surface_foret <- get_wfs(x = point_foret,
                         layer = "BDTOPO_V3:foret_publique")

# Création du bbox de la forêt
bbox_foret <- st_bbox(surface_foret)

# Récupération des parkings dans la zone de la forêt via OSM
query_parking <- opq(bbox = bbox_foret) |>
  add_osm_feature(key = 'amenity', value = c('parking'))
osm_parking <- osmdata_sf(query_parking)
parking_sf <- osm_parking$osm_points

# Intersection des parkings avec la surface de la forêt
parking_foret <- st_intersection(parking_sf["geometry"],
                                 surface_foret["geometry"])

# Conversion des coordonnées des parkings pour le calcul des isochrones
parking_coord <- as.data.frame(st_coordinates(parking_foret$geometry))

# Calcul des isochrones avec OSRM
options(osrm.server = "https://metric-osrm-backend.lab.sspcloud.fr/")
options(osrm.profile = "driving")
iso <- metricOsrmIso(loc = parking_coord,
                     breaks = c(30),  # Isochrones de 30 minutes
                     exclude = NULL,
                     res = 20,
                     fusion = FALSE,
                     courbes = "isochrones")

# Création de la carte avec le fond de carte OSM
tm_basemap("OpenStreetMap") +  # Ajout du fond de carte OSM
  tm_shape(surface_foret) +
  tm_borders("black", lwd = 3) +  # Bordures de la forêt
  tm_shape(st_as_sfc(st_bbox(surface_foret))) +  # Bounding box de la forêt
  tm_borders("red", lwd = 2) +  # Bordures en rouge
  tm_shape(parking_foret) +  # Parkings dans la forêt
  tm_symbols(size = 0.1, col = "blue", shape = 16, border.col = "black", border.lwd = 0.5) +  # Affichage des parkings
  tm_shape(iso_sf) +  # Isochrones des parkings
  tm_polygons(alpha = 0.3, col = "green", border.col = "darkgreen") +  # Affichage des isochrones
  tm_layout(main.title = "Carte des parkings et isochrones dans la forêt", legend.outside = TRUE)  # Titre et légende
