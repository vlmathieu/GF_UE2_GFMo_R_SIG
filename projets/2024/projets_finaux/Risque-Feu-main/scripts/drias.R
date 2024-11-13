rm(list = ls())


# install.packages(c("sf", "ggplot2", "leaflet", "dplyr", "tidyterra"))


library(sf)
library(ggplot2)
library(leaflet)
library(dplyr)
library(tmap);ttm()
library(terra)
library(tidyverse)
library(stars)
library(raster)

# chargement du jeu de données ----

indices_feu <-
  read.table(
    "D:/COURS_APT/3A/R_SIG_projet/indicesALADIN63_CNRM-CM5_24090913012904838.KEYuAuU7dD1Uudu0Od00fOx.txt",
    sep = ";",
    quote = "\""
  )

safran <- st_read("D:/COURS_APT/3A/R_SIG_projet/safran.gpkg")


# # Fonction pour créer un carré autour d'un point
# point_to_square <- function(point, side_length) {
#   # Calculer le demi côté du carré
#   half_side <- side_length / 2
#   
#   # Extraire les coordonnées du point
#   x <- st_coordinates(point)[1]
#   y <- st_coordinates(point)[2]
#   
#   # Créer les 4 sommets du carré en ajoutant/diminuant le demi côté aux coordonnées du point
#   coords <- matrix(c(x - half_side, y - half_side,  # Coin inférieur gauche
#                      x + half_side, y - half_side,  # Coin inférieur droit
#                      x + half_side, y + half_side,  # Coin supérieur droit
#                      x - half_side, y + half_side,  # Coin supérieur gauche
#                      x - half_side, y - half_side), # Retour au coin inférieur gauche pour fermer le polygone
#                    ncol = 2, byrow = TRUE)
#   
#   # Créer un polygone à partir de ces coordonnées
#   polygon <- st_polygon(list(coords))
#   
#   return(polygon)  # Retourner uniquement le polygone, pas sfc
# }
# 
# # Longueur des côtés des carrés
# side_length <- 8000  # en mètres
# 
# # Créer les polygones carrés
# polygons_list <- lapply(indices_feu_sf$geometry, point_to_square, side_length)
# 
# # Convertir cette liste de polygones en une collection géométrique simple (sfc)
# sf_squares <- st_sf(geometry = st_sfc(polygons_list))
# 
# # Assigner la même projection que les points originaux
# st_crs(sf_squares) <- st_crs(indices_feu_sf)
# 
# 
# 
# # Visualiser les points et les carrés
# ggplot() +
#   geom_sf(data = sf_squares, fill = 'transparent', color = 'blue')+
#   geom_sf


# # Charger les packages nécessaires
# library(sf)
# library(dplyr)
# 
# # Exemple: suppose que 'points_sf' soit ton objet sf avec des points,
# # et 'polygons_sf' soit ton objet sf avec des polygones.
# 
# # Étape 1: Calculer les centroïdes des polygones
# centroids_sf <- st_centroid(safran)
# 
# # Étape 2: Calculer les distances entre chaque point et les centroïdes des polygones
# # Le résultat est une matrice où chaque ligne représente un point et chaque colonne un centroïde de polygone
# distance_matrix <- st_distance(indices_feu_sf, centroids_sf)
# 
# # Étape 3: Trouver le polygone le plus proche de chaque point
# # Appliquer which.min pour chaque ligne de la matrice de distances pour trouver l'indice du polygone le plus proche
# closest_polygons_idx <- apply(distance_matrix, 1, which.min)
# 
# # Étape 4: Associer les points avec les polygones les plus proches
# # Récupérer les polygones correspondants à ces indices
# closest_polygons <- safran[closest_polygons_idx, ]
# 
# # Optionnel: Joindre les deux sf
# result_sf <- indices_feu_sf %>%
#   mutate(closest_polygon = closest_polygons$geometry)
# 
# # Visualiser le résultat (facultatif)
# plot(st_geometry(safran), col = "lightblue", border = "blue")
# plot(st_geometry(indices_feu_sf), col = "red", pch = 19, add = TRUE)
# plot(st_geometry(centroids_sf), col = "green", pch = 4, add = TRUE)


get.drias.gpkg <-
  function(safran = safran,
           indices_feu = indices_feu) {
   
     # transformation de indices_feu au format sf ----
    
    indices_feu_sf <-
      st_as_sf(indices_feu, coords = c("V3", "V2"), crs = 4326)
    
    # indices_feu_sf <- terra::project(indices_feu_sf, "EPSG:2154")
    # ne fonctionne pas pour les objets sf
      
      indices_feu_sf <- st_transform(indices_feu_sf, crs = 2154)
    
    #  reprojection de la couche safran en L93 ----
    
    safran <- st_transform(safran, crs = 2154)
    
    # jointure safran/drias ----
    
    safran_drias <- st_join(safran, indices_feu_sf)
    
    safran_drias <- safran_drias[!is.na(safran_drias$V1), ]
    
    safran_drias_proche <- safran_drias[safran_drias$V5 == "H1", ]
    safran_drias_moyen <- safran_drias[safran_drias$V5 == "H2", ]
    safran_drias_lointain <- safran_drias[safran_drias$V5 == "H3", ] 
    
    # drias_ifmx_proche <- safran_drias_proche[, c("V12", "location")]
    # drias_ifmx_moyen <- safran_drias_moyen[, "V12"]
    # drias_ifmx_lointain <- safran_drias_lointain[, "V12"]
    
    
    
    
    
    # transformation des sf au format spatVector puis spatRaster ----    
    
    # ifmx_proche_vec <- terra::vect(drias_ifmx_proche)
    # ifmx_moyen_vec <- terra::vect(drias_ifmx_moyen)
    # ifmx_lointain_vec <- terra::vect(drias_ifmx_lointain)
    # 
    # r <- raster(extent(ifmx_proche_vec), res=0.01)
    # ifmx_proche_rast <- terra::rasterize(ifmx_proche_vec, r, fun=sum)
    # 
    # safran_drias_vec <- terra::vect(safran_drias_selec)

    
    # arrondi des indicateurs à l'unité
    
    safran_drias$V12 <- round(safran_drias$V12, 0)
    safran_drias$V12 <- as.integer(safran_drias$V12)
    

    
    drias_proche_raster <- rast(safran_drias_proche)

    
    raster_drias_proche <- stars::st_rasterize(safran_drias_proche %>% 
                                            dplyr::select(V12, 
                                                          location))
    raster_drias_moyen <- stars::st_rasterize(safran_drias_moyen %>% 
                                                 dplyr::select(V12, 
                                                               location))
    raster_drias_lointain <- stars::st_rasterize(safran_drias_lointain %>% 
                                                 dplyr::select(V12, 
                                                               location))

    raster_drias_proche <- as(raster_drias_proche, "SpatRaster")
    raster_drias_moyen <- as(raster_drias_moyen, "SpatRaster")
    raster_drias_lointain <- as(raster_drias_lointain, "SpatRaster")
    
    # reprojection des couches en WGS84
    
    raster_drias_proche <- project(raster_drias_proche, "EPSG:4326")
    raster_drias_moyen <- project(raster_drias_moyen, "EPSG:4326")
    raster_drias_lointain <- project(raster_drias_lointain, "EPSG:4326")
    
    # rasterize ----
    
    writeRaster(raster_drias_proche, "drias.gpkg",
                gdal = c("APPEND_SUBDATASET=YES",
                         "RASTER_TABLE=IFMX_RCP8_5_PROCHE"))
    writeRaster(raster_drias_moyen, "drias.gpkg",
                gdal = c("APPEND_SUBDATASET=YES",
                         "RASTER_TABLE=IFMX_RCP8_5_MOYEN"))
    writeRaster(raster_drias_lointain, "drias.gpkg",
                gdal = c("APPEND_SUBDATASET=YES",
                         "RASTER_TABLE=IFMX_RCP8_5_LOINTAIN"))
    
  }

get.drias.gpkg(safran, indices_feu)



