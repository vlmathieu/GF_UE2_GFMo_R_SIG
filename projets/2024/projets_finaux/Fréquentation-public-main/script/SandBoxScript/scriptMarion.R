library(osmdata)
library(osrm)
library(happign)
library(sf)
library(tmap)
library(dplyr)
library(ggplot2)

tmap_mode("view")


# Code Paul ----

# Define the area of interest and query for parking
nancy <- get_apicarto_cadastre("54395", type = "commune") |>
  st_transform(4326) |>
  st_bbox()

# script Loris ----
bbox_foret <- getbb("Forêt d'Amance, France")
foret <- opq(bbox = bbox_foret) %>%
  add_osm_feature(key = "landus", value = "forest") %>%
  osmdata
ggplot() + geom_sf(data = foret$osm_polygons, fill = "darkgreen", color = "black")


# test 1 ----
point_foret <- mapedit::drawFeatures()

surface_foret <- get_wfs(x = point_foret,
                         layer = "LANDCOVER.FORESTINVENTORY.V2:formation_vegetale")
qtm(surface_foret)

chemin_shapefile <- "C:/Collège-Lycée-Etudes/FIF Nancy 3ème année/Semaine R/projet/surface_foret.shp"
st_write(surface_foret,
         chemin_shapefile,
         "surface_foret.shp",
         layer = "surface_foret")

#foret <- read_sf(system.file("extdata/surface_foret.shp", package = "happign"))
foret <- st_read(chemin_shapefile)

foret_carto <- get_apicarto_cadastre(foret)


# test 2 ----
point_foret <- mapedit::drawFeatures()
communes_foret <- get_wfs(x = point_foret,
                          layer = "ADMINEXPRESS-COG.LATEST:commune")
qtm(communes_foret)

communes_insee <- as.list(communes_foret$insee_com)

foret2 <- get_apicarto_cadastre(c("54100","54012"), type = "parcelle")


# brouillon selection parking ----
surface_foret2 <- st_as_sf(as.data.frame(surface_foret))
parking_foret <- parking_sf[st_within(parking_sf["geometry"], surface_foret2["geometry"], sparse = FALSE), ]

surface_foret2 <- st_transform(st_as_sf(as.data.frame(surface_foret2)), st_crs(parking_sf))
within_indices <- unlist(st_within(parking_sf, surface_foret2))
parking_foret <- parking_sf[within_indices, ]


# script en cours ----

point_foret <- mapedit::drawFeatures()  # sélection point forêt
surface_foret <- get_wfs(x = point_foret,
                         layer = "BDTOPO_V3:foret_publique")  # délimitation surface forêt (polygone)
perimetre_foret <- st_boundary(surface_foret)  # délimitation périmètre forêt (ligne)

buffer_perim_foret <- st_buffer(perimetre_foret,
                                500)  # aller chercher 500m autour de la foret
surface_rech_parking <- st_union(buffer_perim_foret["geometry"],
                                 surface_foret["geometry"])  # faire nouvelle surface de recherche des parking dans la forêt et à 500m autour


bbox_foret <- st_bbox(surface_rech_parking)  # création bbox pour la suite


query_parking <- opq(bbox = bbox_foret) |>
  add_osm_feature(key = 'amenity',
                  value = c('parking'))
osm_parking <- osmdata_sf(query_parking)
parking_sf <- osm_parking$osm_points  # extraction points parking

parking_foret <- st_intersection(parking_sf["geometry"],
                                 surface_rech_parking["geometry"])  # sélection points parking en forêt et 500m autour

dist_parking <- st_is_within_distance(parking_foret,
                                      dist = 100)  # distance 100m entre points
parking_foret$cluster_id <- sapply(seq_along(dist_parking),
                                   function(i) min(dist_parking[[i]]))  # création colonne pour donner n° de groupe
groupe_parking <- parking_foret %>%
  group_by(cluster_id) %>%  # fusionner les points avec mm n° de groupe
  summarise(geometry = st_centroid(st_combine(geometry))) %>%  # créer un unique point centroid pour les nouveaux groupes
  ungroup()

iso_30 <- osrmIsochrone(groupe_parking["geometry"],
                       breaks = 30,
                       res = 20)
tmap_options(check.and.fix = TRUE)

iso_30 <- osrmIsochrone(groupe_parking["geometry"],
                        breaks = 30,
                        res = 20)
tmap_options(check.and.fix = TRUE)

commune_iso <- get_wfs(x = iso_30,
                       layer = "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune")
commune_5000 <- commune_iso[commune_iso$population >= 5000, ]


query_water <- opq(bbox = bbox_foret) |>
  add_osm_feature(key = 'natural', value = c('water'))
osm_water <- osmdata_sf(query_water)
water_sf <- osm_water$osm_polygons  # extraction polygones zones en eau



qtm(surface_foret)
qtm(perimetre_foret)
qtm(surface_rech_parking)
qtm(parking_sf)
qtm(parking_foret)
qtm(groupe_parking)
qtm(iso_30)
qtm(commune_5000)
qtm(water_sf)
qtm(buff_20_parking)
qtm(parking_filtre)
qtm(iso_30)


# amenity parking
# boundary forest
# amenity townhall
# place municipality
# highway
# natural wood
# natural water
