

library(readxl)
library(tmap)
library(happign)
library(mapedit)
library(tidyverse)
library(sf)
library(stars)
View(happign::get_layers_metadata("wfs"))
zone <- mapedit::drawFeatures() 

fonction_desserte <- function (shp,
                               resolution = 100){
  desserte <- happign::get_wfs(shp, "BDTOPO_V3:troncon_de_route")
  
  desserte_accessible_V <- subset(desserte, nature!="Sentier")
                               
  desserte_accessible_V <- subset(desserte_accessible_V, nature!="Escalier")
                               
  desserte_accessible_V$score[desserte_accessible_V$nature=="Route empierrée"] <- 5
                              
   desserte_accessible_V$score[desserte_accessible_V$nature=="Route à 1 chaussée"] <- 2
                               
   desserte_accessible_V$score[desserte_accessible_V$nature=="Route à 2 chaussées"] <- 1
                               
   desserte_accessible_V$score[desserte_accessible_V$nature=="Chemin"] <- 9

    # Rasteriser le vecteur
                               
   raster_desserte <- st_rasterize(desserte_accessible_V %>% 
                                     dplyr::select(score,geometry),
                                   res = resolution) 
                              
    write_stars(raster_desserte, "desserte.tif")
                               
    return(raster_desserte)
                               }










