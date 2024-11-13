# Projet 5 - Récupération et traitement du MNT
# Récupérer le MNT de la zone d'étude avec happign et calculer les pentes
# Auteur : Agnès Davière (GF, AgroParisTech)
# Contact : agnes.daviere@agroparistech.fr
# Dernière mise à jour : 10 septembre 2024

# Librairies ----
librarian::shelf(happign,terra,tmap,sf)
tmap_mode("view")

# Dossier de travail ----
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Fonctions temporaires ----

draw <- function(raster,vecteur){
  tm_shape(raster)+
    tm_raster()+
    tm_shape(vecteur)+
    tm_borders("black", lwd = 2)
}

# Fonctions intermédiaires ----

code.insee <- function(code_post, libelle){
  info_com <- get_apicarto_codes_postaux(code_post)
  ligne <- which(info_com$libelleAcheminement == libelle)
  code_insee <- info_com$codeCommune[[ligne]]
  return(code_insee)
}

get.cadastre <- function(code_insee, section, num_parc){
  zone_parca <- get_apicarto_cadastre(code_insee,
                                      type = "parcelle",
                                      code_com = NULL,
                                      section = section,
                                      numero = num_parc,
                                      dTolerance = 0L,
                                      source = "PCI"
                                      )
  return(zone_parca)
}

get.mnt <- function(zone_parca){
  mnt_layer_name <- "ELEVATION.ELEVATIONGRIDCOVERAGE"
  zone_parca_buffered <- st_buffer(zone_parca, dist = 100)
  mnt <- get_wms_raster(x = zone_parca_buffered,
                        layer = mnt_layer_name, 
                        crs = 2154,
                        res = 25,
                        rgb = FALSE,
                        filename = "mnt.tif",
                        overwrite = TRUE
                        )
  return(mnt)
}

calculate.slope <- function(mnt){
  classes <- c(0, 5, 15, 30, 45, 60, 90)
  pente <- terrain(mnt,
                   v = "slope",
                   unit = "degrees",
                   filename = "pente.tif",
                   overwrite = TRUE
  )
  pente_classee <- classify(pente, classes)
  return(pente_classee)
}

save.raster.gpkg <- function(SpatRaster) {
  layer_name <- names(SpatRaster)
  writeRaster(SpatRaster,
              filename = "pente.gpkg",
              filetype = "GPKG",
              gdal = c("APPEND_SUBDATASET=YES",
                       paste0("RASTER_TABLE=", layer_name))
  )
}

save.sf.gpkg <- function(sf) {
  gpkg_path <- paste0(dirname(rstudioapi::getActiveDocumentContext()$path),"/pente.gpkg")
  layer_name <- deparse(substitute(sf))
  st_write(sf,
           gpkg_path,
           layer = layer_name,
           append = TRUE
           )
}

save.gpkg <- function(SpatRaster, sf){
  save.raster.gpkg(SpatRaster)
  save.sf.gpkg(sf)
}  

# Fonction principale ----

get.slope <- function(code_post, libelle, section, num_parc){
  code_insee <- code.insee(code_post, libelle)
  zone_parca <- get.cadastre(code_insee, section, num_parc)
  mnt <- get.mnt(zone_parca)
  pente <- calculate.slope(mnt)
  save.gpkg(pente, zone_parca)
  draw(pente, zone_parca)
}

# Exemple ---- 

code_post = "74420"
libelle <- "SAXEL"
section <- list(NULL)
num_parc <- list(NULL)

get.slope(code_post, libelle, section, num_parc)
