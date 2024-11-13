# https://hackmd.io/@hOaFaD2DS4WcOzNXU6j7vg/HJThOyWvU

librarian::shelf(happign, osmdata, tmap, sf, dplyr, ggplot2, spplot, viridis)
library(tmap);ttm() #switch entre plot et viewer

# Test fonction ----
?st_buffer
?sp.polygons
?st_union
?st_overlaps
?st_line_merge
?st_intersection
?group_by.sf
?summary


# Buffer de ligne dans un polygone ----
# Choix de la ville de Charmes (88130)

point_foret_polygone <- mapedit::drawFeatures()  # Placer notre polygone

get_apikeys()   # Chercher les données dans IGN

# Recup des routes passant dans ce polygone
routes_polygone <- get_wfs(point_foret_polygone,
                  "BDTOPO_V3:troncon_de_route",
                  spatial_filter = "intersects") 

buffer_routes <- st_buffer(routes_polygone,15)  # Buffer des lignes routes

# Visualisation des buffers 
tm_shape(buffer_routes)+
  tm_polygons(col = 'red') +
  tm_shape(point_foret_polygone)+ 
  tm_borders('white')


# Buffer à partir d'un point ---- 
point_foret_point <- mapedit::drawFeatures()  # Placer notre point
buffer_point <- st_buffer(point_foret_point,1500)  # Buffer des lignes routes

# Visualisation des buffers 
tm_shape(buffer_point)+
  tm_polygons(col = 'blue') 


# Voir quand 2 buffers se superposent ---- 

st_combine(buffer_routes)
combinaison_buffer <- st_union(buffer_point, buffer_routes)

# overlaps_buffers <- st_overlaps(buffer_point, buffer_routes)

tm_shape(combinaison_buffer)+
  tm_polygons(col = 'blue')

class(combinaison_buffer)

# Merging <- group_by(overlaps_buffers,add = TRUE)


# Mes fonctions ----
# Fonctions buffer sur plusieurs points : 

point_foret <- mapedit::drawFeatures()  # un point

surface_foret <- get_wfs(x = point_foret,
                         layer = "BDTOPO_V3:foret_publique")

bbox_foret <- st_bbox(surface_foret)

query_parking <- opq(bbox = bbox_foret) |>
  add_osm_feature(key = 'amenity', value = c('parking'))

osm_parking <- osmdata_sf(query_parking)

parking_sf <- osm_parking$osm_points

# Fonctions pour mettre buffer autour des parkings ou points d'entrées

buffer.points <- function(sf){
  st_buffer(sf,1000)
}

testbufferpoint <- buffer.points(parking_sf)

# Visualisation 

tm_shape(testbufferpoint)+
  tm_polygons(col = 'blue')

# Fusion des polygines buffer

fusion.buffer <- function(sf){
  fusion <- st_union(sf)  # Fusion des polygones
  correction <- st_make_valid(fusion)  # Correction des polygones invalides
}

buffer_ts_parkings <- fusion.buffer(testbufferpoint)
class(buffer_ts_parkings)

# Visualiser les polygones corrigés

tm_shape(buffer_ts_parkings) +
  tm_polygons(col = 'blue')

# Configuration de tmap pour corriger les erreurs de géométrie si nécessaire

tmap_options(check.and.fix = TRUE)


# Save data ---- 

getwd()
st_write(buffer_ts_parkings, 
         "projet1.gpkg",
         layer = "parkings_buffer")


# Faire un buffer différencié selon l'importance de la route ----
# https://bdtopoexplorer.ign.fr/troncon_de_route#attribute_555

# Plus l'importance de la route est proche de 1, plus le buffer est grand


is_empty_sf <- function(sf) {
  return(nrow(sf) == 0)
}

buffer.diff.routes <- function(sf) {
  # Initialisation de la carte avec les bordures
  map <- tm_shape(surface_foret) + 
    tm_borders(col = 'black')
  
  # Ajouter les buffers de taille et couleur différentes
  map <- map + buffer.taille.couleur(sf, 1, 1500, 'inferno')
  map <- map + buffer.taille.couleur(sf, 2, 1100, 'red')
  map <- map + buffer.taille.couleur(sf, 3, 1000, 'orange')
  map <- map + buffer.taille.couleur(sf, 4, 800, 'yellow')
  map <- map + buffer.taille.couleur(sf, 5, 500, 'cyan')
  map <- map + buffer.taille.couleur(sf, 6, 250, 'green')
  
  # Afficher la carte
  print(map)
}

# Modification de buffer.taille.couleur pour retourner l'objet tm
buffer.taille.couleur <- function(sf, y, x, color){
  # y = importance ; x = dist ; color = couleur
  routes <- subset(sf, sf$importance == y)
  buffer <- st_buffer(routes, dist = x)
  
  if (!is_empty_sf(buffer)) {
    return(tm_shape(buffer) + tm_polygons(col = color))
  } 
}

# faire fonction qui prend sf importance, nvx de buffer et couleur. Puis carte en individuel
# bien checker que bonne class(routes_1)
buffer.diff.routes <- function(sf) {
  routes_1 <- subset(sf, importance == 1)
  routes_2 <- subset(sf, importance == 2)
  routes_3 <- subset(sf, importance == 3)
  routes_4 <- subset(sf, importance == 4)
  routes_5 <- subset(sf, importance == 5)
  routes_6 <- subset(sf, importance == 6)
  buffer_1 <- st_buffer(x = routes_1, dist = 1500)
  buffer_2 <- st_buffer(x = routes_2, dist = 1100)
  buffer_3 <- st_buffer(x = routes_3, dist = 1000)
  buffer_4 <- st_buffer(x = routes_4, dist = 800)
  buffer_5 <- st_buffer(x = routes_5, dist = 500)
  buffer_6 <- st_buffer(x = routes_6, dist = 250)

  # Initialisation de la carte
  map <- tm_shape(point_foret_polygone) + 
    tm_borders(col = 'black')
  
  # Ajouter chaque couche si elle n'est pas vide
  if (!is_empty_sf(buffer_1)) {
    map <- map + tm_shape(buffer_1) + tm_polygons(col = 'inferno')
  }
  
  if (!is_empty_sf(buffer_2)) {
    map <- map + tm_shape(buffer_2) + tm_polygons(col = 'red')
  }
  
  if (!is_empty_sf(buffer_3)) {
    map <- map + tm_shape(buffer_3) + tm_polygons(col = 'orange')
  }
  
  if (!is_empty_sf(buffer_4)) {
    map <- map + tm_shape(buffer_4) + tm_polygons(col = 'yellow')
  }
  
  if (!is_empty_sf(buffer_5)) {
    map <- map + tm_shape(buffer_5) + tm_polygons(col = 'cyan')
  }
  
  if (!is_empty_sf(buffer_6)) {
    map <- map + tm_shape(buffer_6) + tm_polygons(col = 'green')
  }

}

BuffDiff1 <- buffer.diff.routes(buffer_routes)
tmap_mode("view")  # Passe en mode interactif
print(BuffDiff1) 


# palette <- c("red", "blue")

# buffer_routes_union <- st_union(st_union(buffer_routes$buffer))
# tm_shape(polygons_sf) +
#  tm_polygons(col = "value", palette = palette, title = "Valeur")

#tm_shape(buffer_routes) +
 # tm_polygons(col = "importance", 
  #         lwd = 2, 
   #        palette = "Dark2")
# tm_shape(buffer_routes)+  tm_polygons(col = 'red') +
#  tm_shape(point_foret_polygone)+ 
  # tm_borders('white')  

# Buffer différencié selon la proximité du parking
