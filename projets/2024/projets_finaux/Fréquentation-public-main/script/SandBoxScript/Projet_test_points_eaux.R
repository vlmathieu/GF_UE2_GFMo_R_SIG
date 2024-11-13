#ceci est un test de Tifaine pour récupérer les points d'eaux
library(happign)
library(tmap);ttm()
library(osmdata)
library(sf)
library(ggmap)

#on regarde ce qui existe dans la bdd IGN
get_apikeys()
layers_env <- get_layers_metadata("wfs","environnement")

#on récupère le périmètre de la forêt
point_foret <- mapedit::drawFeatures()  # sélection point forêt
surface_foret <- get_wfs(x = point_foret,
                         layer = "BDTOPO_V3:foret_publique")  # délimitation surface forêt (polygone)
perimetre_foret <- st_boundary(surface_foret)  # délimitation périmètre forêt (ligne)
qtm(perimetre_foret)

#on récupère les points d'eaux avec OSM

bbox_foret <- st_bbox(surface_foret)  # création bbox pour la suite


query_water <- opq(bbox = bbox_foret) |>
  add_osm_feature(key = c('water', 'waterway'),
                   value = c('river', 'oxbox', 'canal', 'ditch', 'lake',
                            'reservoir', 'pond', 'stream_pool', 'river',
                            'stream'))

query_waterway <- opq(bbox = bbox_foret) |>
  add_osm_feature(key = 'waterway',
                  value = c('stream', 'watefall'))

query_natural <- opq(bbox = bbox_foret) |>
  add_osm_feature(key = 'natural',
                  value = c('water'))

all_eau <- c(osmdata_sf(query_water), osmdata_sf(query_waterway), osmdata_sf(query_natural))

all_eau_points_sf <- all_eau$osm_points
all_eau_lignes_sf <- all_eau$osm_lines
all_eau_polygones_sf <- all_eau$osm_polygons

all_eau_points_foret <- st_intersection(all_eau_points_sf["geometry"],
                                           surface_foret["geometry"])
all_eau_lignes_foret <- st_intersection(all_eau_lignes_sf["geometry"],
                                        surface_foret["geometry"])
all_eau_polygones_foret <- st_intersection(all_eau_polygones_sf["geometry"],
                                           surface_foret["geometry"])

qtm(all_eau_points_foret)
qtm(all_eau_lignes_foret)
qtm(all_eau_polygones_foret)
