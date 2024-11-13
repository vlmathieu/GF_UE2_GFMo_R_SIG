------------------------------------------------------------------------
  
title: "Test script R -projet"
author: "Killian BAUE"
Contact: "killian.baue@agroparistech.fr"
format: R

df-print: paged
self-contained: true

editor: visual

------------------------------------------------------------------------
  
# Chargement des librairies ----

library(readxl)
library(happign)
library(tmap)
library(sf)
library(dplyr)
library(terra)
tmap_mode("view")

# Importation des données cadastrales de la zone d'étude ----

nombres <- 1500:1600
vecteur_chaine <- sprintf("%04d", nombres)

Saxel_parca_pci <- get_apicarto_cadastre(
  x = "74261",               
  type = "parcelle",         
  section = "0A",            
  numero = vecteur_chaine,   
  source = "pci",            
  progress = TRUE            
)

qtm(Saxel_parca_pci)

# Re-projeter les données en Lambert 93 ----

Saxel_parca_pci_2154 <- st_transform(Saxel_parca_pci, crs = 2154)

st_write(Saxel_parca_pci_2154, "testRprojet.gpkg", layer = "Saxel_parca_pci_2154", append = TRUE)

st_layers("testRprojet.gpkg")

# Orthophotos et altimétrie ----

IRC_layer_name <- "ORTHOIMAGERY.ORTHOPHOTOS.IRC"
IRC <- get_wms_raster(x = Saxel_parca_pci, layer = IRC_layer_name, res = 10)

tm_shape(IRC) + tm_rgb() + tm_shape(Saxel_parca_pci) + tm_borders(col = 'white')

MNT_layer_name <- "RGEALTI-MNT_PYR-ZIP_FXX_LAMB93_WMS"
MNS_layer_name <- "ELEVATION.ELEVATIONGRIDCOVERAGE.HIGHRES.MNS"

MNT <- get_wms_raster(x = Saxel_parca_pci,
                      layer = MNT_layer_name,
                      res = 10,
                      rgb = FALSE)
MNS <- get_wms_raster(x = Saxel_parca_pci, layer = MNS_layer_name, res = 10, rgb = FALSE)


## Importation du MNT de la zone d'étude
#buffer_zone_parca <- st_buffer(zone_parca, dist = 100)
#bbox <- st_bbox(buffer_zone_parca) #récupérer les coordonnées de la zone buffer


# essayer d'ajouter le mnt au gpkg ainsi qu'un buffer de 100m autour de la parcelle

tm_shape(MNT)+
  tm_raster()+
  tm_shape(Saxel_parca_pci)+
  tm_borders("black", lwd = 2)

# Calcul de la pente ----

pente <- terrain(MNT,
                 v = "slope",
                 unit = "degrees",
                 filename = "C:/Users/keepc/Downloads/pente_slope.tif", # spécifiez le nom de fichier avec l'extension
                 overwrite = TRUE
)

classes <- c(0, 5, 15, 30, 45, 60, 90)
classes_pente <- classify(pente, classes)
plot(classes_pente)

tm_shape(classes_pente)+
  tm_raster()+
  tm_shape(Saxel_parca_pci)+
  tm_borders("black", lwd = 2)

tmap_mode("view")


qtm(MNT) + tm_raster() + tm_shape(Saxel_parca_pci) + tm_borders(col = 'white')

# Chargement des vecteurs routier et hydrographique ----

routes <- get_wfs(Saxel_parca_pci, "BDTOPO_V3:troncon_de_route", spatial_filter = "intersects")
troncon_hydro <- get_wfs(Saxel_parca_pci, "BDTOPO_V3:troncon_hydrographique", spatial_filter = "intersects")

routes_l93 <- st_transform(routes, crs = 2154)
troncon_hydro_l93 <- st_transform(troncon_hydro, crs = 2154)

tm_shape(Saxel_parca_pci) +
  tm_borders() +
  tm_shape(routes_l93) +
  tm_lines(col = "red", lwd = 1, legend.col.title = "Routes") +
  tm_shape(troncon_hydro_l93) +
  tm_lines(col = "blue", lwd = 1, legend.col.title = "Ruisseaux") +
  tm_layout(legend.outside = TRUE)

# test d'une fonction permettant d'afficher des erreurs de dessertes ----

# Charger les bibliothèques nécessaires


# Fonction pour détecter les erreurs de dessertes (sans les tronçons hydrographiques)
detect_dessertes_errors <- function(routes, crs_code = 2154) {
  # Convertir en CRS souhaité
  routes_l93 <- st_transform(routes, crs = crs_code)
  
  # Trouver les erreurs de discontinuité des routes
  # Union des routes et vérification des discontinuités
  routes_buffer <- st_buffer(routes_l93, dist = 0.01)
  routes_union <- st_union(routes_buffer)
  routes_discontinuities <- st_difference(routes_union, st_union(st_buffer(routes_l93, dist = -0.01)))
  
  # Identifier les routes non connectées
  # Créer une table des intersections pour trouver les connexions
  intersections <- st_intersects(routes_l93, routes_l93, sparse = FALSE)
  disconnected_routes <- which(rowSums(intersections) == 1)
  
  # Création d'un tableau des erreurs
  errors_table <- tibble(
    Type = c("Discontinuité de route", "Routes non connectées"),
    Description = c(
      paste0("Nombre de discontinuités trouvées : ", nrow(routes_discontinuities)),
      paste0("Nombre de routes non connectées : ", length(disconnected_routes))
    )
  )
  
  # Affichage du tableau
  print(errors_table)
  
  # Créer un objet de carte avec tmap
  map <- tm_shape(routes_l93) +
    tm_lines(col = "red", lwd = 1, legend.col.title = "Routes") +
    tm_shape(routes_discontinuities) +
    tm_polygons(col = "yellow", border.col = "black", border.lwd = 3, alpha = 0.7, legend.col.title = "Discontinuités de Routes") +
    tm_shape(routes_l93[disconnected_routes, ]) +
    tm_lines(col = "orange", lwd = 2, legend.col.title = "Portions de Routes Non Connectées") +
    tm_layout(legend.outside = FALSE, legend.position = c("left", "bottom"))  # Afficher la légende dans le viewer
  
  # Afficher la carte dans le viewer
  tmap_mode("view")
  print(map)
}

# Appeler la fonction avec vos données
detect_dessertes_errors(routes)



# Buffers ----

buffer_60_80m <- st_difference(st_buffer(routes_l93, 80), st_buffer(routes_l93, 60))
buffer_40_60m <- st_difference(st_buffer(routes_l93, 60), st_buffer(routes_l93, 40))
buffer_20_40m <- st_difference(st_buffer(routes_l93, 40), st_buffer(routes_l93, 20))
buffer_0_20m <- st_difference(st_buffer(routes_l93, 20), st_buffer(routes_l93, 0))

buffer_60_80m_sf <- st_sf(geometry = st_geometry(buffer_60_80m), Buffer = "60 à 80 m")
buffer_40_60m_sf <- st_sf(geometry = st_geometry(buffer_40_60m), Buffer = "40 à 60 m")
buffer_20_40m_sf <- st_sf(geometry = st_geometry(buffer_20_40m), Buffer = "20 à 40 m")
buffer_0_20m_sf <- st_sf(geometry = st_geometry(buffer_0_20m), Buffer = "0 à 20 m")

buffers_combined <- rbind(buffer_60_80m_sf, buffer_40_60m_sf, buffer_20_40m_sf, buffer_0_20m_sf)
buffers_combined <- st_make_valid(buffers_combined)

routes_simplified <- st_simplify(routes_l93, dTolerance = 1)

tm_shape(Saxel_parca_pci) +
  tm_borders() +
  tm_shape(buffers_combined) +
  tm_fill(col = "Buffer", 
          palette = c("#FF4500", "#FFA07A", "#87CEEB", "#add8e6"),
          alpha = 0.3, 
          legend.col.title = "Distance") +
  tm_shape(routes_simplified) +
  tm_lines(col = "red", lwd = 2, legend.col.title = "Routes") +
  tm_shape(troncon_hydro_l93) +
  tm_lines(col = "blue", lwd = 2, legend.col.title = "Ruisseaux") +
  tm_layout(legend.outside = TRUE, 
            legend.outside.position = "right",
            legend.title.size = 1.5, 
            legend.text.size = 1.2, 
            legend.bg.color = "white", 
            legend.bg.alpha = 0.8)

# Croisement pente X distance







# Exportation Geopackage ----

st_write(routes_l93, "pplmt_data.gpkg", layer = "routes", append = TRUE)
st_write(troncon_hydro_l93, "pplmt_data.gpkg", layer = "troncon_hydro", append = TRUE)

writeRaster(IRC, "pplmt_data.gpkg", filetype = "GPKG", gdal = c("APPEND_SUBDATASET=YES", "RASTER_table=IRC"))
writeRaster(MNH, "pplmt_data.gpkg", filetype = "GPKG", gdal = c("APPEND_SUBDATASET=YES", "RASTER_table=MNH"))



