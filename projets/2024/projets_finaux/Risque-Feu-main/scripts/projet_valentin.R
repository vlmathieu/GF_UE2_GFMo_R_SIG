#Informations_principales----
title: "presentation_happign_fif"
author: "Valentin GOUFFON"
format: html


#Import_library----
library(openxlsx)
library(readxl)
library(happign)
library(tmap);tmap_mode("view")
library(sf)
library(terra)
library(mapedit)
library(crosstalk)
library(mapview)
library(shiny)
library(dplyr)
library(leaflet)


#Enregistrement_donnees----
base_path <- "C:/Users/vg27540/Documents/AgroParisTech/3A/R/GF_UE2_GFMo_R_SIG-main/"
gpkg_path <- file.path(base_path, "RFF.gpkg")


#Dessiner_zone----
get_import_zone <- function(){
  # Code utilisé pour importer un shape----
  #shp_path <- file.choose()  # Ouvrir les fichiers locaux du PC
  #shp_etude <<- st_read(shp_path)  # Importer le shapefile sélectionné ds l'env
  # Convertir l'objet en sf si nécessaire
  # "finished" contient la géométrie dessinée
  #shp_etude <<- st_as_sf(drawn_zone$finished)
  
  
  # Code pour dessiner une features avec mapedit----
  # Créer une carte leaflet centrée sur la France
  # Longitude, Latitude approximative de la France
  france_center <- c(2.2137, 46.2276)  
  map <- leaflet() %>%
    addTiles() %>%
    setView(lng = france_center[1], lat = france_center[2], zoom = 6)
  
  # Utiliser cette carte avec drawFeatures pour dessiner la zone d'étude
  drawn_zone <- drawFeatures(map = map)
  
  # Vérifier si quelque chose a été dessiné
  if (is.null(drawn_zone)) {
    stop("Aucune zone n'a été dessinée. Veuillez dessiner une zone avant de continuer.")
  }
  
  # Convertir l'objet dessiné en sf si nécessaire
  shp_etude <- st_as_sf(drawn_zone)
  
  # Vérifier si la conversion a bien fonctionné
  if (is.null(shp_etude)) {
    stop("Erreur lors de la conversion en objet sf.")
  }
  # Assurez-vous que les coordonnées sont correctement transformées
  # Les données placette IFN étant en lambert 93 (2154)
  shp_etude <- st_transform(shp_etude, 2154)
  
  # Sauvegarder la zone d'étude dans l'environnement
  shp_etude <<- shp_etude
  
  
  return (shp_etude)  # return les géométrie chargé
}

get_import_zone()


#Import_dalle_DRIAS----
dalle <- get_wfs(x= shp_etude, layer = "ADMINEXPRESS-COG.LATEST:departement") #script PAUL

qtm(dalle)


#Intersection_DRIAS_BD_FORET_V2----
Peupelement <- get_wfs(dalle, layer = "LANDCOVER.FORESTINVENTORY.V2:formation_vegetale")


#Import_MNT----
View(get_layers_metadata("wms-r"))
shp_mnt <- "C:/Users/vg27540/Documents/AgroParisTech/3A/R/Nouveau dossier/FORMATION_VEGETALE.shp"
mnt <- st_read(shp_mnt)

plot(st_geometry(mnt))

elevation <- get_wms_raster(x= mnt, layer = "ELEVATION.CONTOUR.LINE", rgb = FALSE)

tm_shape(elevation)+
  tm_raster()


#Import_Carroyage_DFCI----
shp_mnt <- "C:/Users/vg27540/Documents/AgroParisTech/3A/R/Nouveau dossier/FORMATION_VEGETALE.shp"
zone <- st_read(shp_mnt)

plot(st_geometry(zone))

carroyage <- get_wms_raster(x= zone, layer = "GEOGRAPHICALGRIDSYSTEM.DFCI", rgb = FALSE)

tm_shape(carroyage)+
  tm_raster()





#Affichage_carte_finale----
pouliot <- c(latitude = Peuplement, longitude = Peuplement)

carte_pouliot <- leaflet(width = 910, height = 440)

carte_pouliot <- addTiles(carte_pouliot)

carte_pouliot <- addMarkers(
  map = carte_pouliot,
  lng = pouliot["longitude"],
  lat = pouliot["latitude"],
  label = "TFV"  # Texte en glissant le curseur
)


carte_pouliot <- addMeasure(
  map = carte_pouliot,
  position = "bottomleft",
  primaryLengthUnit = "metres",
  primaryAreaUnit = "sqmeters",
  activeColor = "#FF0000",
  completedColor = "#7D4479"
)

carte_pouliot

