# A propos du script ----

# Objectif du script : Représentation cartographique de la fréquentation en 
# forêt et de son impact, outil à destination du gestionnaire

# Auteurs : Cattanéo Tifaine, Gonzalez Loris, Pidoux Ella, Vergnol Marion

# Contacts : tifaine.cattaneo@agroparistech.fr,
# loris.gonzalez@agroparistech.fr,
# ella.pidoux@agroparistech.fr,
# marion.vergnol@agroparistech.fr

# Dernière mise à jour : 


# Installation des packages et chargement library ----

# Pour installer et mettre à jour les packages
install.packages(librarian)
librarian::shelf(happign,  # pour les données Web et IGN
                 osmdata,   # pour manipuler les données d'openstreetmap
                 osrm,  # pour manipuler les données d'openstreetmap
                 sf,  # pour manipuler les données vecteurs
                 tmap,  # pour la visualisation des cartes
                 dplyr)  # pour manipuler les données dans les tables

tmap_mode("view")  # passe en mode interactif pour l'affichage des cartes


# Dossier de travail ----
setwd("E:/APT/GF/UE2_R_SIG/ProjetR")


# Fonctions ----

# Fonction pour la création d'un buffer de x mètres et choix des couleurs
buffer.points <- function(sf, x, color){
  buffer <- st_buffer(sf, x)
  map <- tm_shape(buffer) + tm_polygons(col = color)
}

# Fonction qui crée des buffers de pression qui se cumulent en distance
pression.buffer <- function(sf){
  grde_pression <- st_buffer(sf, 500)
  moy_pression <- st_buffer(grde_pression, 250)
  ptit_pression <- st_buffer(moy_pression, 250)
  return(list(
    grde_pression = grde_pression,
    moy_pression = moy_pression,
    ptit_pression = ptit_pression
  ))
}

# Fonction pour vérifier que le sf est vide
is_empty_sf <- function(sf) {
  return(nrow(sf) == 0)
}

# Fonction qui crée un buffer de distance x m en fonction de l'importance y de
# la route
buffer.route.taille <- function(sf, y, x){
  routes <- subset(sf,
                   sf$importance == y)
  buffer <- st_buffer(routes,
                      dist = x)
  
  if (!is_empty_sf(buffer)) {
    return(buffer)
  } 
}

# Fonction pour visualisation d'un buffer de distance x mètres pour une route
# d'importance y et attribution d'une couleur
buffer.taille.couleur <- function(sf, y, x, color){
  routes <- subset(sf,
                   sf$importance == y)
  buffer <- st_buffer(routes,
                      dist = x)
  
  if (!is_empty_sf(buffer)) {
    return(tm_shape(buffer) + tm_polygons(col = color))
  } 
}

# Fonction de visulation avec couleur des buffers de routes
buffer.diff.routes <- function(sf) {
  # initialisation de la carte avec les bordures
  map <- tm_shape(surface_foret) + 
    tm_borders(col = 'black')
  
  # ajouter les buffers de taille et couleur différentes
  map <- map + buffer.taille.couleur(sf, 1, 150, 'red')
  map <- map + buffer.taille.couleur(sf, 2, 100, 'orange')
  map <- map + buffer.taille.couleur(sf, 3, 80, 'yellow')
  map <- map + buffer.taille.couleur(sf, 4, 50, 'cyan')
  map <- map + buffer.taille.couleur(sf, 5, 20, 'green')
  
  # afficher la carte
  print(map)
}

# Fonction permettant l'enregistrement dans un géopackage
sauvegarde.gpkg <- function(nom_gpkg) {
  sf_layers <- list(  # liste des sf et leur nom de couche
    surface_foret = "surface_foret",
    groupe_parking = "groupe_parking",
    grde_pression_parking_sf = "grde_pression_parking_sf",
    moy_pression_parking_sf = "moy_pression_parking_sf",
    ptit_pression_parking_sf = "ptit_pression_parking_sf",
    iso_30 = "iso_30",
    commune_5000 = "commune_5000",
    route_foret = "route_foret",
    chemin_foret = "chemin_foret",
    chemin_freq = "chemin_freq",
    chemin_osm_foret = "chemin_osm_foret",
    chemin_osm_freq = "chemin_osm_freq",
    route_imp1 = "route_imp1",
    route_imp2 = "route_imp2",
    route_imp3 = "route_imp3",
    route_imp4 = "route_imp4",
    route_imp5 = "route_imp5",
    all_eau_lignes_parking = "all_eau_lignes_parking",
    all_eau_polygones_parking = "all_eau_polygones_parking",
    cours_eau_parking = "cours_eau_parking",
    plan_eau_parking = "plan_eau_parking",
    detail_eau_parking = "detail_eau_parking"
  )

  for (sf_name in names(sf_layers)) {
    obj <- tryCatch(get(sf_name), error = function(e) NULL)  # récupère l'objet
    # et retourne NULL si inexistant
    if (!is.null(obj) && !is_empty_sf(obj)) {
      st_write(st_transform(obj, 2154), 
               nom_gpkg, 
               layer = sf_layers[[sf_name]])
    }
  }
}


# Partie 1 : Identification de la forêt ----

# Sélection de la forêt par un point
point_foret <- mapedit::drawFeatures()

# Délimitation de la surface de la forêt
surface_foret <- get_wfs(x = point_foret,
                         layer = "BDTOPO_V3:foret_publique")


# Partie 2 : Identification des points de parking en forêt et à 500m autour ----

# Faire une surface englobant la forêt et les 500m alentour
surface_rech_parking <- st_buffer(surface_foret,
                                  500)

# Création d'une bbox
bbox_foret <- st_bbox(surface_rech_parking)

# Recherche des points de parking référencés dans openstreetmap
query_parking <- opq(bbox = bbox_foret) |>
  add_osm_feature(key = 'amenity',
                  value = c('parking'))

# Création d'une couche vecteur avec les points de parking
osm_parking <- osmdata_sf(query_parking)
parking_sf <- osm_parking$osm_points

# Suppression des points au-delà de la zone de recherche (forêt et 500m autour)
parking_foret <- st_intersection(parking_sf["geometry"],
                                 surface_rech_parking["geometry"])

# Regrouper les points situés à moins de 200m les uns des autres et création
# d'un unique point centroïde pour les nouveaux groupements

# Création pour chaque point de parking d'une liste de points de parking situés
# à moins de 200m
dist_parking <- st_is_within_distance(parking_foret,
                                      dist = 200)

# Crééation d'un vecteur vide de longueur le nombre de points de parking
clusters <- rep(NA, length(dist_parking))

# Attribution d'un numéro à chaque groupe de points de parking à moins de 200m
cluster_id <- 1
for (i in seq_along(dist_parking)) {  # on parcours la liste des parkings
  if (is.na(clusters[i])) {
    clusters[i] <- cluster_id  # si le point n'a pas déjà un n° de cluster on
    # lui donne le n° actuel
    queue <- dist_parking[[i]]  # on crée une liste avec les voisins identifiés
    # à moins de 200m
    while (length(queue) > 0) {
      j <- queue[1]
      queue <- queue[-1]
      if (is.na(clusters[j])) {  # on vérifie que le point n'est pas déjà dans
        # dans un autre groupe et on l'ajoute au groupe actuel
        clusters[j] <- cluster_id
        queue <- c(queue, dist_parking[[j]])
      }
    }
    cluster_id <- cluster_id + 1  # on passe au groupe de points suivant
  }
}

parking_foret$cluster_id <- clusters  # on crée une colonne avec les n° de groupe

groupe_parking <- parking_foret %>%  # on calcule le centroïde de chaque groupe
  # de points avant de les fusionner
  group_by(cluster_id) %>%
  summarise(geometry = st_centroid(st_combine(geometry))) %>%
  ungroup()

# Visualisation des points de parking
qtm(groupe_parking)

# Buffer de pression du grand public autour des parkings 
pression_gp_parking <- pression.buffer(groupe_parking)

# Accéder aux buffers de pression des parkings
grde_pression_parking_sf <- pression_gp_parking$grde_pression
moy_pression_parking_sf <- pression_gp_parking$moy_pression
ptit_pression_parking_sf <- pression_gp_parking$ptit_pression

# Visualisation des buffers parking
map <- tm_shape(surface_foret) + 
  tm_borders(col = 'black')
map <- map + tm_shape(ptit_pression_parking_sf) + tm_polygons(col = 'green')
map <- map + tm_shape(moy_pression_parking_sf) + tm_polygons(col = 'orange')
map <- map + tm_shape(grde_pression_parking_sf) + tm_polygons(col = 'red')
print(map)


# Partie 3 : Pression sur les chemins aux abords des parkings ----

# Données pédestres issues de l'IGN
troncons <- get_wfs(x = surface_foret,
                    layer = "BDTOPO_V3:troncon_de_route",
                    spatial_filter = "intersects")

chemin_foret <- troncons[troncons$nature %in% c("Sentier",
                                                "Chemin",
                                                "Route empierrée"), ]

chemin_freq <- st_intersection(chemin_foret["geometry"],
                               pression_gp_parking$ptit_pression["geometry"])

# Visualisation des chemins les plus fréquentés
# Message d'erreur peut apparaître lors de la visualisation si 0 chemin
qtm(chemin_freq)

# Comparaison avec les données openstreetmap
query_chemin_osm <- opq(bbox = bbox_foret) |>
  add_osm_feature(key = 'highway',
                  value = c('track',  # route à usage forestier ou agricole
                            'cycleway',  # voie vélo
                            'footway',  # sentier pédestre
                            'bridleway',  # sentier équestre
                            'path'))  # sentier non spécifique

osm_chemin <- osmdata_sf(query_chemin_osm)
chemin_osm_sf <- osm_chemin$osm_lines  

chemin_osm_foret <- st_intersection(chemin_osm_sf["geometry"],
                                    surface_foret["geometry"])
chemin_osm_freq <- st_intersection(chemin_osm_foret["geometry"],
                                   pression_gp_parking$ptit_pression["geometry"]) 

# Visualisation des chemins osm les plus fréquentés
# Message d'erreur peut apparaître lors de la visualisation si 0 chemin
qtm(chemin_osm_freq)


# Partie 4 : Identification des villes de plus de 5000 habitants à moins ----
# de 30 min en voiture des parkings de la forêt

# Calcul des isochrones de 30 min en voiture des parkings de la forêt
iso_30 <- osrmIsochrone(groupe_parking["geometry"],
                        breaks = 30,
                        res = 20)

# Récupération des informations des communes dans l'isochrone
commune_iso <- get_wfs(x = iso_30,
                       layer = "LIMITES_ADMINISTRATIVES_EXPRESS.LATEST:commune")

# Sélection des communes de plus de 5000 habitants
commune_5000 <- commune_iso[commune_iso$population >= 5000, ]

# Pression des communes selon le nombre d'habitants 
ptit_commune <- commune_5000[commune_5000$population <= 7000, ]
moy_commune <- commune_5000[commune_5000$population > 7000 & commune_5000$population <= 10000, ]
grde_commune <- commune_5000[commune_5000$population > 10000, ]

# Visualisation de la classification des communes
# (Possibilité de former un buffer autour des limites communales)
pression_commune <- buffer.points(ptit_commune, x = 0, color = "green") +
  buffer.points(moy_commune, x = 0, color = "yellow") +
  buffer.points(grde_commune, x = 0, color = "red")
print(pression_commune)

# Calcul du nombre total d'habitants dans les villes de l'isochrone
nb_hab_pression <- sum(commune_5000[["population"]])
nb_hab_pression

# Partie 5 : Pression des routes ----

# Faire nouvelle surface de recherche des routes dans la forêt et à 50m autour
# (pour inclure les routes longeant les limites de la forêt sans les croiser)
surface_rech_route <- st_buffer(surface_foret,
                                50)

# Sélection des routes traversant et longeant la forêt
route_foret <- get_wfs(surface_rech_route,
                        "BDTOPO_V3:troncon_de_route",
                        spatial_filter = "intersects") 

# Création de buffer selon la nature des routes
# importance 1 = liaison entre métropoles
route_imp1 <- buffer.route.taille(route_foret, 1, 150)
# importance 2 = liaison entre départements
route_imp2 <- buffer.route.taille(route_foret, 2, 110)
# importance 3 = liaison entre communes dans un même département
route_imp3 <- buffer.route.taille(route_foret, 3, 100)
# importance 4 = voies rapides dans une commune
route_imp4 <- buffer.route.taille(route_foret, 4, 80)
# importance 5 = routes dans une commune 
route_imp5 <- buffer.route.taille(route_foret, 5, 50)

# Visualisation de la pression des routes
pression_route <- buffer.diff.routes(route_foret)
print(pression_route)


# Partie 6 : Identification des zones d'intérêt "eau" ----

# Récupération des données d'openstreetmap
query_water <- opq(bbox = bbox_foret) |>
  add_osm_feature(key = 'water',
                  value = c('river',  # rivière
                            'oxbox',  # méandre
                            'canal',  # canal
                            'ditch',  # fossé
                            'lake',  # lac
                            'reservoir',  # lac artificiel
                            'pond',  # petit lac artificiel
                            'stream_pool'))  # petite gorge

query_waterway <- opq(bbox = bbox_foret) |>
  add_osm_feature(key = 'waterway',
                  value = c('stream',  # ruisseau
                            'watefall'))  # cascade

query_natural <- opq(bbox = bbox_foret) |>
  add_osm_feature(key = 'natural',
                  value = c('water'))  # masse d'eau naturelle

# Fusion des éléments "eau" obtenus avec les  key différentes
all_eau <- c(osmdata_sf(query_water),
             osmdata_sf(query_waterway),
             osmdata_sf(query_natural))

# Création d'une couche vecteur selon la nature des éléments "eau"
all_eau_points_sf <- all_eau$osm_points
all_eau_lignes_sf <- all_eau$osm_lines
all_eau_polygones_sf <- all_eau$osm_polygons

# Sélection des éléments "eau" dans la forêt et à 1km autour des parkings
all_eau_points_foret <- st_intersection(all_eau_points_sf["geometry"],
                                        surface_foret["geometry"])
all_eau_points_parking <- st_intersection(all_eau_points_foret["geometry"],
                                          pression_gp_parking$ptit_pression["geometry"])

all_eau_lignes_foret <- st_intersection(all_eau_lignes_sf["geometry"],
                                        surface_foret["geometry"])
all_eau_lignes_parking <- st_intersection(all_eau_lignes_foret["geometry"],
                                          pression_gp_parking$ptit_pression["geometry"])

all_eau_polygones_foret <- st_intersection(all_eau_polygones_sf["geometry"],
                                           surface_foret["geometry"])
all_eau_polygones_parking <- st_intersection(all_eau_polygones_foret["geometry"],
                                             pression_gp_parking$ptit_pression["geometry"])

# Visualisation des différents éléments "eau" à moins d'1km des parkings
qtm(all_eau_points_parking)
qtm(all_eau_lignes_parking)
qtm(all_eau_polygones_parking)

# Comparaison avec les données de l'IGN 
cours_eau <- get_wfs(surface_foret,
                     "BDTOPO_V3:cours_d_eau",
                     spatial_filter = "intersects") 
plan_eau <- get_wfs(surface_foret,
                    "BDTOPO_V3:plan_d_eau",
                    spatial_filter = "intersects") 
detail_eau <- get_wfs(surface_foret,
                      "BDTOPO_V3:detail_hydrographique",
                      spatial_filter = "intersects")

cours_eau_foret <- st_intersection(cours_eau["geometry"],
                                   surface_foret["geometry"])
plan_eau_foret <- st_intersection(plan_eau["geometry"],
                                  surface_foret["geometry"])
detail_eau_foret <- st_intersection(detail_eau["geometry"],
                                    surface_foret["geometry"])

cours_eau_parking <- st_intersection(cours_eau_foret["geometry"],
                                     pression_gp_parking$ptit_pression["geometry"])
plan_eau_parking <- st_intersection(plan_eau_foret["geometry"],
                                    pression_gp_parking$ptit_pression["geometry"])
detail_eau_parking <- st_intersection(detail_eau_foret["geometry"],
                                      pression_gp_parking$ptit_pression["geometry"])

# Visualisation des éléments "eau" de l'IGN à moins d'1km des parkings
# Message d'erreur peut apparaître lors de la visualisation si 0 points d'eau
qtm(cours_eau_parking)
qtm(plan_eau_parking)
qtm(detail_eau_parking)


# Partie 7 : Sauvegarde des données créées dans un géopackage ----

# Chemin d'accès où sera enregistré le gpkg
getwd()

dossier_gpkg <- sauvegarde.gpkg("impact_freq.gpkg")
