library(readxl)
library(tmap)
library(happign)
library(mapedit)
library(terra)
library(sf)
library(tidyverse)
library(stars)
View(happign::get_layers_metadata("wfs"))
zone <- mapedit::drawFeatures()


fonction_bat <- function (shp,
                         resolution = 100,
                         buffer = 50){
  batiment <- happign::get_wfs(shp,"BDTOPO_V3:batiment")
                         
  batiment_buf <- st_buffer(x = batiment, 
                            buffer) 
  batiment_buf$score <- 1
                         
  raster_batiment <- stars::st_rasterize(batiment_buf %>% 
                                    dplyr::select(score, geometry))
  write_stars(raster_batiment, "batiment.tif")
          
  return(raster_batiment)
                         }

batiment <- happign::get_wfs(zone,
                             "BDTOPO_V3:batiment"
)
qtm(batiment)

batiment_buf <- st_buffer(x = batiment,
              50)
qtm(batiment_buf)

raster_batiment <- st_rasterize(batiment_buf,
                                res = 100) 

write_stars(raster_batiment, "batiment.tif")
