rm(list=ls())
install.packages("raster")

library(terra)
library(raster)
library(sf)
library(happign)
library(tmap);ttm()
library(tidyverse)
library(stars)

# import du couvert végétal via une zone sélectionnée

happign::get_apikeys()
#View(get_layers_metadata("wfs"))
X = mapedit::drawFeatures()
pplt_aleatoire <- happign::get_wfs(X,"LANDCOVER.FORESTINVENTORY.V2:formation_vegetale")

peuplement_descrip <- function(X){
  pplt_aleatoire <- happign::get_wfs(X,"LANDCOVER.FORESTINVENTORY.V2:formation_vegetale")
  
  plot(pplt_aleatoire)
  pplt_aleatoire$inflammability <- ifelse(
    pplt_aleatoire$tfv_g11 == "Forêt fermée feuillus", 20,
    ifelse(pplt_aleatoire$tfv_g11== "Forêt fermée sans couvert arboré",10,
           ifelse(pplt_aleatoire$tfv_g11 == "Forêt ouverte feuillus", 30,
                  ifelse(pplt_aleatoire$tfv_g11 == "Forêt fermée conifères", 70,
                         ifelse(pplt_aleatoire$tfv_g11 == "Forêt ouverte conifères", 80,
                                ifelse(pplt_aleatoire$tfv_g11 == "Lande", 50,
                                       ifelse(pplt_aleatoire$tfv_g11 == "Peupleraie", 10, 50)))))))
  
  
  pplt_aleatoire$combustibility <-ifelse(
    pplt_aleatoire$tfv_g11 == "Forêt fermée feuillus", 800,
    ifelse(pplt_aleatoire$tfv_g11== "Forêt fermée sans couvert arboré",750,
           ifelse(pplt_aleatoire$tfv_g11 == "Forêt ouverte feuillus",700,
                  ifelse(pplt_aleatoire$tfv_g11 == "Forêt fermée conifères", 300,
                         ifelse(pplt_aleatoire$tfv_g11 == "Forêt ouverte conifères", 200,
                                ifelse(pplt_aleatoire$tfv_g11 == "Lande", 500,
                                       ifelse(pplt_aleatoire$tfv_g11 == "Peupleraie", 700, 500)))))))
  
  inflama_raster <- stars::st_rasterize(pplt_aleatoire %>% 
                                        dplyr::select(inflammability, 
                                                                  geometry))
  
  combusti_raster <- stars::st_rasterize(pplt_aleatoire %>% 
                                          dplyr::select(combustibility, 
                                                        geometry))
  return(c(inflama_raster, combusti_raster))
}

plot(peuplement_descrip(X))








