library(happign)
library(tmap);ttm()
library(osmdata)
library(sf)

#Sélection d'une forêt via un point sur carte intéractive
point_foret <- mapedit::drawFeatures()  

#Récupération de la surface de la forêt publique de la zone
surface_foret <- get_wfs(x = point_foret,
                         layer = "BDTOPO_V3:foret_publique",
                         spatial_filter = "intersects")

perimetre_foret <- st_boundary(surface_foret)

#Création de la zone d'extraction pour les données OSM
bbox_foret <- st_bbox(surface_foret)  


query_sentier <- opq(bbox = bbox_foret) |>
  add_osm_feature(key = 'highway', #utilisé pour décrire des routes et chemins
                  value = c('track', #route à usage forestier ou agricole
                            'cycleway', #voie vélo
                            'footway', #sentier pédestre
                            'bridleway', #sentier équestre
                            'path')) #sentier non spécifique

osm_sentier <- osmdata_sf(query_sentier)

# Extraction des divers sentiers d'OpenStreeMap
sentier_sf <- osm_sentier$osm_lines  

#Intersections des sentiers avec le périmètre élargie de la forêt
#pour pouvoir récupérer les sentiers en bordure

sentier_foret <- st_intersection(sentier_sf["geometry"],
                                 surface_foret["geometry"]) 
