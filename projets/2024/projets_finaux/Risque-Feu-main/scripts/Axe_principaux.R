
library(readxl)
library(tmap)
library(happign)
library(mapedit)
library(tidyverse)
library(sf)
library(stars)
library(dplyr)
library(ggplot2)
View(happign::get_layers_metadata("wfs"))
zone <- mapedit::drawFeatures() 

fonction_axe_principaux <- function(shp,
                                    resolution = 100){
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
  
  raster_Axe_principaux <- stars::st_rasterize(Axe_principaux %>% 
                                  dplyr::select(score),
                                res = resolution) 
  
  write_stars(raster_Axe_principaux, "Axe_principaux.tif")
  
  return(raster_Axe_principaux)
  # Afficher le raster avec tmap
  tm_shape(raster_Axe_principaux) +
    tm_raster("score", palette = "-viridis") +  # Choisir une palette de couleurs
    tm_layout(legend.outside = TRUE)  # Afficher la légende à l'extérieur
  
  }






