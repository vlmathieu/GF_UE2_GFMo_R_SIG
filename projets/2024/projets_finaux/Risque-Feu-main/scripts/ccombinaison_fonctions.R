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

# Mes fonctions ----

# inflammabilité + combustibilité peuplements
peuplement_inflammabilite <- function(X){
  pplt_aleatoire <- happign::get_wfs(X,"LANDCOVER.FORESTINVENTORY.V2:formation_vegetale")
  
  pplt_aleatoire$inflammability <- ifelse(
    pplt_aleatoire$tfv_g11 == "Forêt fermée feuillus", 20,
    ifelse(pplt_aleatoire$tfv_g11== "Forêt fermée sans couvert arboré",10,
           ifelse(pplt_aleatoire$tfv_g11 == "Forêt ouverte feuillus", 30,
                  ifelse(pplt_aleatoire$tfv_g11 == "Forêt fermée conifères", 70,
                         ifelse(pplt_aleatoire$tfv_g11 == "Forêt ouverte conifères", 80,
                                ifelse(pplt_aleatoire$tfv_g11 == "Lande", 50,
                                       ifelse(pplt_aleatoire$tfv_g11 == "Peupleraie", 10, 50)))))))
  
  
  inflama_raster <- stars::st_rasterize(pplt_aleatoire %>% 
                                          dplyr::select(inflammability, geometry))
  
  return(inflama_raster)
}

peuplement_combustibilite <- function(X){
  pplt_aleatoire <- happign::get_wfs(X,"LANDCOVER.FORESTINVENTORY.V2:formation_vegetale")
  
  pplt_aleatoire$combustibility <-ifelse(
    pplt_aleatoire$tfv_g11 == "Forêt fermée feuillus", 800,
    ifelse(pplt_aleatoire$tfv_g11== "Forêt fermée sans couvert arboré",750,
           ifelse(pplt_aleatoire$tfv_g11 == "Forêt ouverte feuillus",700,
                  ifelse(pplt_aleatoire$tfv_g11 == "Forêt fermée conifères", 300,
                         ifelse(pplt_aleatoire$tfv_g11 == "Forêt ouverte conifères", 200,
                                ifelse(pplt_aleatoire$tfv_g11 == "Lande", 500,
                                       ifelse(pplt_aleatoire$tfv_g11 == "Peupleraie", 700, 500)))))))
  
  combusti_raster <- stars::st_rasterize(pplt_aleatoire %>% 
                                           dplyr::select(combustibility, geometry),
                                         )
  return(combusti_raster)
}


# desserte

fonction_desserte <- function (shp){
  desserte <- happign::get_wfs(shp, "BDTOPO_V3:troncon_de_route")
  
  desserte_accessible_V <- subset(desserte, nature!="Sentier")
  
  desserte_accessible_V <- subset(desserte_accessible_V, nature!="Escalier")
  
  desserte_accessible_V$score[desserte_accessible_V$nature=="Route empierrée"] <- 5
  
  desserte_accessible_V$score[desserte_accessible_V$nature=="Route à 1 chaussée"] <- 2
  
  desserte_accessible_V$score[desserte_accessible_V$nature=="Route à 2 chaussées"] <- 1
  
  desserte_accessible_V$score[desserte_accessible_V$nature=="Chemin"] <- 9

  raster_desserte <- st_rasterize(desserte_accessible_V %>% 
                                    dplyr::select(score)) 
  
  return(raster_desserte)
}

# bâtiments sensibles

fonction_bat <- function (X,
                          buffer = 50){
  batiment <- happign::get_wfs(X,"BDTOPO_V3:batiment")
  print(st_crs(batiment)) 
  
  batiment_buf <- st_buffer(x = batiment, 50)
  
  intersections <- st_intersects(batiment_buf, batiment)
  
  batiment_buf$nb_batiments <- lengths(intersections)
  
  batiment_buf$classe_bâtis <- ifelse(
    batiment_buf$nb_batiments <= 3,"bâtis isolé",
    ifelse(batiment_buf$nb_batiments <= 50,"bâtis diffus","bâtis sans classe"))
                             
  batiment_buf$score <- case_when(
    batiment_buf$classe_bâtis == "bâtis isolé" ~ 1,       
    batiment_buf$classe_bâtis == "bâtis diffus" ~ 2,     
    batiment_buf$classe_bâtis == "bâtis sans classe" ~ 3)
  
  raster_batiment <- stars::st_rasterize(batiment_buf %>% 
                                           dplyr::select(score))
  write_stars(raster_batiment, "batiment.tif")
  
  return(raster_batiment)
}


# axes routiers

fonction_axe_principaux <- function(zone){
  route <- happign::get_wfs(zone,
                            "BDTOPO_V3:route_numerotee_ou_nommee")
  
  route_departementale <- route %>% mutate(type_de_route = ifelse(
    type_de_route == "Départementale", type_de_route, NA))
  
  route_autoroute <- route %>% mutate(type_de_route = ifelse(
    type_de_route == "Autoroute", type_de_route, NA))
  
  route_nommée <- route %>% mutate(type_de_route = ifelse(
    type_de_route == "Route_nommée", type_de_route, NA))
  
  route_intercommunale <- route %>% mutate(type_de_route = ifelse(
    type_de_route == "Route intercommunale", type_de_route, NA))
  
  Axe_principaux <- rbind(
    route_departementale, route_autoroute, route_intercommunale, route_nommée)
  
  Axe_principaux$score[Axe_principaux$type_de_route=="Départementale"] <- 1
  
  Axe_principaux$score[Axe_principaux$type_de_route=="Autoroute"] <- 1
  
  Axe_principaux$score[Axe_principaux$type_de_route=="Route_nommée"] <- 1
  
  Axe_principaux$score[Axe_principaux$type_de_route=="Route intercommunale"] <- 1
  
  
  raster_Axe_principaux <- stars::st_rasterize(Axe_principaux %>% 
                                                 dplyr::select(type_de_route)) 
    # ce n'est pas type de route qu'il faut renvoyer mais le score et j'ai pas réussi à le faire marcher avec score
  
  
  return(raster_Axe_principaux)
}


# Pente et topographie


# Addition des données raster
 
addition <- function(){
  X = mapedit::drawFeatures()
  liste_fonctions <- list(peuplement_inflammabilite, 
                          peuplement_combustibilite,
                          fonction_desserte,
                          fonction_bat,
                          fonction_axe_principaux)
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


