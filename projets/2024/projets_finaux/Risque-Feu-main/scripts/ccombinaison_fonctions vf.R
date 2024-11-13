# Cartographie des risques incendie
# Sujet prospectif
# Auteurs : DEBAS Adrien, FERGANI Nadjim, GIOVINAZZO Esteban, 
#           GOUFFON Valentin, VETTER Johann
# Contact : adrien.debas@agroparistech.fr, nadjim.fergani@agroparistech.fr,
#           esteban.giovinazzo@agroparistech.fr, 
#           valentin.gouffon@agroparistech.fr, johann.vetter@agroparistech.fr
# Dernière mise à jour : septembre 2024


# Mes librairies ----
library(raster)
library(terra)
library(dplyr)
library(stars)
library(readxl)
library(tmap)
library(happign)
library(mapedit)
library(tidyverse)
library(sf)

# Set working directory ----

# Chargement du jeu de données DRIAS Grand-Est----

indices_feu <- read.table(
    "indicesALADIN63_CNRM-CM5_24090913012904838.KEYuAuU7dD1Uudu0Od00fOx.txt",
    sep = ";",
    quote = "\"")

safran <- st_read("safran.gpkg")




# Mes sous-fonctions ----

# Inflammabilité du peuplement 
peuplement_inflammabilite <- function(X){
  pplt_aleatoire <- happign::get_wfs(X,
                   "LANDCOVER.FORESTINVENTORY.V2:formation_vegetale")
  
  pplt_aleatoire$inflammability <- ifelse(
    pplt_aleatoire$tfv_g11 == "Forêt fermée feuillus", 2,
    ifelse(pplt_aleatoire$tfv_g11 == "Forêt fermée sans couvert arboré", 1,
    ifelse(pplt_aleatoire$tfv_g11 == "Forêt ouverte feuillus", 3,
    ifelse(pplt_aleatoire$tfv_g11 == "Forêt fermée conifères", 7,
    ifelse(pplt_aleatoire$tfv_g11 == "Forêt ouverte conifères", 8,
    ifelse(pplt_aleatoire$tfv_g11 == "Lande", 5,
    ifelse(pplt_aleatoire$tfv_g11 == "Peupleraie", 1, 5)))))))
  
  
  inflama_raster <- stars::st_rasterize(pplt_aleatoire %>% 
                                          dplyr::select(inflammability, 
                                                        geometry))
  
  return(inflama_raster)
}

# Combustibilité du peuplement
peuplement_combustibilite <- function(X){
  pplt_aleatoire <- happign::get_wfs(X,
                    "LANDCOVER.FORESTINVENTORY.V2:formation_vegetale")
  
  pplt_aleatoire$combustibility <-ifelse(
    pplt_aleatoire$tfv_g11 == "Forêt fermée feuillus", 80,
    ifelse(pplt_aleatoire$tfv_g11 == "Forêt fermée sans couvert arboré", 75,
    ifelse(pplt_aleatoire$tfv_g11 == "Forêt ouverte feuillus", 70,
    ifelse(pplt_aleatoire$tfv_g11 == "Forêt fermée conifères", 30,
    ifelse(pplt_aleatoire$tfv_g11 == "Forêt ouverte conifères", 20,
    ifelse(pplt_aleatoire$tfv_g11 == "Lande", 50,
    ifelse(pplt_aleatoire$tfv_g11 == "Peupleraie", 70, 50)))))))
  
  combusti_raster <- stars::st_rasterize(pplt_aleatoire %>% 
                                           dplyr::select(combustibility, 
                                                         geometry))
                                         
  return(combusti_raster)
}


# Desserte permettant un accès aux pompiers et diminuant le risque

fonction_desserte <- function (X){
  desserte <- happign::get_wfs(X, "BDTOPO_V3:troncon_de_route")
  
  desserte_accessible_V <- subset(desserte, nature!="Sentier")
  
  desserte_accessible_V <- subset(desserte_accessible_V, nature != "Escalier")
  
  desserte_accessible_V$score[desserte_accessible_V$nature 
                              == "Route empierrée"] <- 3
  
  desserte_accessible_V$score[desserte_accessible_V$nature 
                              == "Route à 1 chaussée"] <- 2
  
  desserte_accessible_V$score[desserte_accessible_V$nature
                              == "Route à 2 chaussées"] <- 1
  
  desserte_accessible_V$score[desserte_accessible_V$nature 
                              == "Chemin"] <- 4

  raster_desserte <- st_rasterize(desserte_accessible_V %>% 
                                    dplyr::select(score)) 
  
  return(raster_desserte)
}

# Bâtiments sensibles : buffer à 50m autour des batiments


fonction_bat <- function (X,
                          buffer = 50){
  batiment <- happign::get_wfs(X, "BDTOPO_V3:batiment")
  
  batiment_buf <- st_buffer(x = batiment, 50)
  
  intersections <- st_intersects(batiment_buf, batiment)
  
  batiment_buf$nb_batiments <- lengths(intersections)
  
  batiment_buf$classe_bâtis <- ifelse(
    batiment_buf$nb_batiments <= 3, "bâtis isolé",
    ifelse(batiment_buf$nb_batiments <= 50, "bâtis diffus", "bâtis sans classe"))
  
  batiment_buf$score <- case_when(
    batiment_buf$classe_bâtis == "bâtis isolé" ~ 1,       
    batiment_buf$classe_bâtis == "bâtis diffus" ~ 2,     
    batiment_buf$classe_bâtis == "bâtis sans classe" ~ 3)
  
  raster_batiment <- stars::st_rasterize(batiment_buf %>% 
                                           dplyr::select(score))
  write_stars(raster_batiment, "batiment.tif")
  
  return(raster_batiment)
}

# Axes routiers principaux augmentant le risque de départ d'incendie

fonction_axes_principaux <- function(zone){
  route <- happign::get_wfs(zone,
                            "BDTOPO_V3:route_numerotee_ou_nommee")
  
  route_departementale <- subset(route, type_de_route=="Départementale")
  
  route_autoroute <- subset(route, type_de_route=="Autoroute")
  
  route_nommée <- subset(route, type_de_route=="Route_nommée")
  
  route_intercommunale <- subset(route, type_de_route=="Route intercommunale")
  
  route_européenne <- subset(route, type_de_route=="Route européenne")
  
  Axe_principaux <- rbind(
    route_departementale, route_autoroute, route_intercommunale, route_nommée)
  
  Axe_principaux$score[Axe_principaux$type_de_route=="Départementale"] <- 2
  
  Axe_principaux$score[Axe_principaux$type_de_route=="Autoroute"] <- 2
  
  Axe_principaux$score[Axe_principaux$type_de_route=="Route_nommée"] <- 1
  
  Axe_principaux$score[Axe_principaux$type_de_route=="Route intercommunale"] <- 1
  
  Axe_principaux$score[Axe_principaux$type_de_route=="Route européenne"] <- 1
  
  #Axes_principaux_buff <- st_buffer(Axe_principaux, 15)
  
  raster_Axe_principaux <- stars::st_rasterize(Axe_principaux %>% 
                                                 dplyr::select(score)
                                               ) 
  
  
  
  return(raster_Axe_principaux)}



# DRIAS : effectue un gpkg de résolution 8 x 8 km sur l'ensemble du Grand-Est

get.drias.gpkg <-
  function(safran = safran,
           indices_feu = indices_feu, 
           nomGPKG) {
    
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
    
    # arrondi des indicateurs à l'unité
    
    safran_drias$V12 <- round(safran_drias$V12, 0)
    safran_drias$V12 <- as.integer(safran_drias$V12)
    
    
    
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
    
    # rasterize ----
    
    writeRaster(raster_drias_proche, paste0(nomGPKG,".gpkg"),
                filetype = "GPKG",
                gdal = c("APPEND_SUBDATASET=YES",
                         "RASTER_TABLE=IFMX_RCP8_5_PROCHE"))
    writeRaster(raster_drias_moyen, paste0(nomGPKG,".gpkg"),
                filetype = "GPKG",
                gdal = c("APPEND_SUBDATASET=YES",
                         "RASTER_TABLE=IFMX_RCP8_5_MOYEN"))
    writeRaster(raster_drias_lointain, paste0(nomGPKG,".gpkg"),
                filetype = "GPKG",
                gdal = c("APPEND_SUBDATASET=YES",
                         "RASTER_TABLE=IFMX_RCP8_5_LOINTAIN"))
    
  }



# Addition des données raster en un seul raster
 
addition <- function(){
  X = mapedit::drawFeatures()
  liste_fonctions <- list(peuplement_inflammabilite, 
                          peuplement_combustibilite,
                          fonction_desserte,
                          fonction_bat,
                          fonction_axes_principaux
                          )
  liste_raster <- lapply(liste_fonctions, function(f) f(X))
  
  liste_raster_resampled <- lapply(liste_raster, function(raster) 
    st_warp(raster, liste_raster[[1]]))
  
  
  
  # Initialiser un raster vide pour stocker la somme
  raster_somme <- liste_raster_resampled[[1]]  # Crée un raster vide basé sur le premier raster
  
  # Boucle pour additionner tous les rasters
  for (i in 2:length(liste_raster_resampled)) {
    raster_somme <- raster_somme + liste_raster_resampled[[i]]
  }
  return(raster_somme)}

# Téléchargement des rasters sur un géopackage

addition_gpkg <- function(X = mapedit::drawFeatures(),
                          nomGPKG){
  liste_fonctions <- list(peuplement_inflammabilite, 
                          peuplement_combustibilite,
                          fonction_desserte,
                          fonction_bat,
                          fonction_axes_principaux
  )
  liste_raster <- lapply(liste_fonctions, function(f) f(X))
  liste_raster_conv <- lapply(liste_raster, function(raster) 
    as(raster, "SpatRaster"))
  
  # créer un géopackage avec tous les rasters
  
for (i in 1:length(liste_raster_conv)) {
    # Créez un nom de couche basé sur l'index ou un autre critère
    layer_name <- paste0("layer_", i)  # Par exemple, "layer_1", "layer_2", etc.
    
    # Écrire l'objet Raster dans le GeoPackage avec un nom de couche dynamique
    writeRaster(liste_raster_conv[[i]],
                paste0(nomGPKG, ".gpkg"),
                filetype = "GPKG",
                gdal = c("APPEND_SUBDATASET=YES",
                         paste0("RASTER_TABLE=", layer_name)))}
  get.drias.gpkg(safran, indices_feu, nomGPKG)
  
  return()}






# Affichage des couches sur Leaflet ----

library(leaflet) # package de base
library(leafem) # package de widgets dont "addMouseCoordinates"
library(leaflet.extras)
library(raster)

carte_risques <- function() {
  X = mapedit::drawFeatures()
  
  # charge les rasters et les convertir en SpatRaster pour les utiliser
  
  inflama_raster <- as(peuplement_inflammabilite(X), "SpatRaster")
  combusti_raster <- as(peuplement_combustibilite(X), "SpatRaster")
  raster_desserte <- as(fonction_desserte(X), "SpatRaster")
  raster_batiment <- as(fonction_bat(X), "SpatRaster")
  raster_Axe_principaux <- as(fonction_axes_principaux(X), "SpatRaster")
  
  map <- leaflet() %>%
    addTiles() %>%
    addRasterImage(inflama_raster, opacity = 0.8, 
                   group = "inflama_raster") %>%
    addRasterImage(combusti_raster, opacity = 0.8, 
                   group = "combusti_raster") %>%
    addRasterImage(raster_desserte, opacity = 0.8, 
                   group = "raster_desserte") %>%
    addRasterImage(raster_batiment, opacity = 0.8, 
                   group = "raster_batiment") %>%
    addRasterImage(raster_Axe_principaux,
                   opacity = 0.8,
                   group = "raster_Axe_principaux") %>%
    addLayersControl(
      overlayGroups = c(
        "inflama_raster",
        "combusti_raster",
        "raster_desserte",
        "raster_batiment",
        "raster_Axe_principaux"
      ),
      options = layersControlOptions(collapsed = FALSE)
    )
  map
  
  addMouseCoordinates(map) %>%  
    # Ajout des coordonnées GPS du pointeur de la souris
    addResetMapButton() %>%  # ajout du bouton "reset" pour recentrage carte
    addFullscreenControl() %>% # ajout du basculement en mode plein écran
    addSearchOSM() %>% # ajout de la barre de recherche Openstreetmap
    
    addMiniMap(toggleDisplay = FALSE) # posibilité de réduite la minimap
  
}
