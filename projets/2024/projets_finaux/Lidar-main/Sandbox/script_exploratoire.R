# About this code ----

# Projet pédagogique sur l'utilisation des données LIDAR récentes pour retrouver
# les cloisonnements sur un peuplement
# Il d'agit ici d'un script exploratoire regroupant nosn différentes pistes 
# d'études. Le script final est disponible dans le github : Projet7_lidar

# Auteur : Armange Tristan, Gerval Thomas, Magnier Mathieu, Marie Gabriel
# Contact : tristan.armange@agroparistech.fr
# Contact : thomas.gerval@agroparistech.fr
# Contact : mathieu.magnier@agroparistech.fr
# Contact : gabriel.marie@agroparistech.fr

# Dernière mise à jour : 12 septembre 2024

# Package installation ----

install.packages("happign")
install.packages("sf")
install.packages("tmap")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("purr")
install.packages("stars")
install.packages("terra")
install.packages("jsonlite")
install.packages("deldir")

# Librairies ----

library(sf)  # for vector
library(tmap); tmap_mode("view")  # Set map to interactive
library(dplyr)  # data manipulation
library(ggplot2);sf_use_s2(FALSE)  # Avoid problem with spherical geometry
library(purrr)  # for function facilitation
library(stars)  # for spatial object
library(terra)  # for raster
library(jsonlite)  # to manipulate .json
library(lidR)  # analyse LAS file
library(deldir)  # triangulation

# Set working directory ----

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))  # créer chemin
dir <- getwd()

# Fonctions ----

# Création d'une fonction pour séléctionner une zonne d'étude.
draw.area = function(){
  zone = st_coordinates(st_transform(mapedit::drawFeatures(), crs = 2154))
  y1 = min(zone[, 2])
  x1 = min(zone[, 1])
  y2 = max(zone[, 2])
  x2 = max(zone[, 1])
  return(c(x1,y1,x2,y2))
}

# Création d'une fonction pour télécharger les données LiDAR. 
download.lidar = function(x1, y1, x2, y2) {
  # Créer une séquence de coordonnées avec un pas de 10000
  x = seq(x1, x2, 10000)
  y = seq(y1, y2, 10000)
  
  # Boucle à travers toutes les combinaisons de x et y
  for (i in x) {
    for (j in y) {
      # Construire l'URL pour obtenir les données JSON
      json_url <- paste0("https://data.geopf.fr/private/wfs/?service=WFS&version=2.0.0&apikey=interface_catalogue&request=GetFeature&typeNames=IGNF_LIDAR-HD_TA:nuage-dalle&outputFormat=application/json&bbox=", 
                         i, ",", j, ",", i, ",", j)
      print(paste("Fetching JSON from:", json_url))
      
      # Essayer de récupérer les données JSON
      tryCatch({
        json = fromJSON(txt = json_url)
        
        # Récupérer le lien du fichier .laz à partir des propriétés du JSON
        lien = json[["features"]][["properties"]][["url"]][1]
        
        if (!is.null(lien)) {  # Vérifier que le lien n'est pas nul
          print(paste("Downloading .laz file from:", lien))
          
          # Téléchargement du fichier .laz avec mode binaire
          download.file(lien, 
                        destfile = paste0("dir", i, "_", j, ".laz"),
                        mode = "wb")  # "wb" pour mode binaire
          
          print(paste("Saved file:", paste0(i, "_", j, ".laz")))
        } else {
          print("No valid link found in the JSON response.")
        }
      }, error = function(e) {
        print(paste("Error fetching or downloading data for bbox:", i, j))
        print(e)  # Affiche l'erreur rencontrée
      })
    }
  }
}

# Création d'une fonction pour couper la zone d'étude correspondant au rectangle
cut.area = function(laz, liste){
  clip = clip_rectangle(laz, liste[1], liste[2], liste[3], liste[4])
  return(clip)
}

# Création d'une fonction pour détecter automatiquement les cloisonnements.
# Il s'agit de la v1, le MNT n'est pas pris en compte, il n' y a pas de filtre 
# Laplacien. Elle est plus longue et moins performante que celle présent dans
# le script final. 
detect.cloiso <- function(laz_norm, resolution = 1, threshold = 0.1, 
                    min_length = 10, output_file = "cloisonnements_norm.gpkg") {
  
  if (is.null(laz_norm) || npoints(laz_norm) == 0) {
    stop("Le fichier LAZ est vide ou n'a pas été chargé correctement.")
  }
  
  # 1. Calculer la densité des points
  density <- grid_density(laz_norm, res = resolution)
  
  # 2. Calculer le nombre de retours
  returns <- grid_metrics(laz_norm, ~length(Z), res = resolution)
  names(returns) <- "num_returns"
  
  # 3. MNH (Modèle Numérique de Hauteur)
  mnh <- grid_canopy(laz_norm, res = resolution, algorithm = pitfree())
  names(mnh) <- "mnh_height"
  
  # 4. Empiler les rasters pour les combiner
  combined_stack <- raster::stack(density, returns, mnh)
  
  # Convertir en data frame pour traitement
  combined_df <- as.data.frame(combined_stack, xy = TRUE)
  
  # Vérifier la présence de valeurs NA et appliquer na.rm = TRUE
  combined_df <- na.omit(combined_df)  # Suppression des lignes avec des NA
  
  # 5. Détecter les zones à faible densité, faible nombre de retours et hauteur
  combined_df$low_density <- ifelse(combined_df$density < quantile
                      (combined_df$density, threshold, na.rm = TRUE), 1, 0)
  combined_df$low_returns <- ifelse(combined_df$num_returns < quantile
                      (combined_df$num_returns, threshold, na.rm = TRUE), 1, 0)
  combined_df$low_mnh <- ifelse(combined_df$mnh_height < quantile
                      (combined_df$mnh_height, threshold, na.rm = TRUE), 1, 0)
  
  # 6. Détecter les cloisonnements
  combined_df$cloisonnement <- ifelse(combined_df$low_density == 1 & 
                  combined_df$low_returns == 1 & combined_df$low_mnh == 1, 1, 0)
  
  # 7. Filtrer les zones de cloisonnements
  cloisonnements_points <- combined_df[combined_df$cloisonnement == 1, ]
  
  # 8. Convertir en objet spatial
  if (nrow(cloisonnements_points) > 0) {
    cloisonnements_sf <- st_as_sf(cloisonnements_points, coords = c("x", "y"), 
                                  crs = st_crs(laz_norm))
    
    # 9. Appliquer un buffer et dissoudre pour connecter les points proches
    cloisonnements_buffer <- st_buffer(cloisonnements_sf, 
                                       dist = resolution * 1.5)
    cloisonnements_dissolved <- st_union(cloisonnements_buffer)
    
    # 10. Tentative d'extraction des lignes centrales des polygones
    cloisonnements_lines <- st_cast(cloisonnements_dissolved, "MULTILINESTRING")
    cloisonnements_lines <- st_cast(cloisonnements_lines, "LINESTRING")
    
    # 11. Filtrer les lignes courtes (avec gestion des unités)
    min_length_units <- units::set_units(min_length, "m")
    cloisonnements_filtered <- cloisonnements_lines[st_length
                                      (cloisonnements_lines)> min_length_units]
    
    # Assurez-vous que l'objet est bien un sf
    cloisonnements_filtered <- st_as_sf(cloisonnements_filtered)
    
    # 12. Exporter au format GPKG
    st_write(cloisonnements_filtered, output_file, driver = "GPKG", 
             delete_layer = TRUE)
    message("Cloisonnements exportés vers ", output_file)
    
    return(cloisonnements_filtered)
  } else {
    message("Aucun cloisonnement détecté.")
    return(NULL)
  }
}

# Import data ----

coord <- draw.area()  # sélection de la zone d'étude
download.lidar(coord[1],coord[2],coord[3],coord[4])  # téléchargement du LiDAR

laz_dir <- list.files(dir, 
                      full.names = T, 
                      pattern= '.laz') # Liste les fichiers .laz du directory 

laz <- readLAS(laz_dir)  # Lecture du LAS
laz <- cut.area(laz, coord)  # Découpage du LAS correspondant à la zone d'étude

# Exploring data ----

# Début de l'exploration du LAS
# Avant la création de la fonction cut.area, les fichiers étaient lourds et 
# difficile à afficher

plot(laz)  # Affichage du LAS

# Test du package lidR

laz_soil <- lidR::filter_ground(laz)  # filtre les points correspondant au sol
plot(laz_soil)

mycsf <- csf(TRUE, 1, 1, time_step = 1)  # algo de classification du sol
laz_soil <- classify_ground(laz, mycsf)
plot(laz_soil)  # Résultat différent, canopée encore présente

# Utilisation d'un filtre
laz_soil <-lidR::filter_poi(laz_soil, Classification == 2L & ReturnNumber > 5L)
plot(laz_soil)  # prometteur : cloisos en noir 

# Test de la fonction shp_hline pour détecter les lignes
test <- segment_shapes(laz_soil, shp_hline(th1 = 100, th2 = 2, k = 3), 
                      attribute = "Shape")

plot(test, color = "Shape")  # Résultat décevant

# Création d'un MNH pour observer la couche
chm <- grid_canopy(laz, res = 1, pitfree())
plot(chm)

density <- grid_density(laz, res = 1)  # permet de calculer la densité de point
plot (density)

# Test des différents algorithme de création de MNT

mnt_tin <- rasterize_terrain(laz, 1, tin())
plot(mnt_tin)
plot_dtm3d(mnt_tin)  # permet de visualiser le MNT en 3D
writeRaster(mnt_tin,"mnt_tin.tif")  # pour enregistrer le MNT 

mnt_knnidw <- rasterize_terrain(laz, 1, knnidw())  # algo knnidw
plot(mnt_knnidw)
writeRaster(mnt_knnidw,"mnt_knnidw.tif")

mnt_kriging <- rasterize_terrain(laz, 1, kriging())  # algo kriging
plot(mnt_kriging)
writeRaster(mnt_kriging,"mnt_kriging.tif")

# Test pour observer des différences entre les MNT 

test_1 <- mnt_tin-mnt_knnidw  # différence entre algo tin et knnidw
plot (test_1)  # pas de différence

test_2 <- mnt_tin-mnt_kriging  # différence entre algo tin et kriging
plot (test_2)  # pas de différence
# Il n'y a pas de différence entre les MNT, on choisira le MNT_tin


# Tentative de normaliser le fichier .laz pour mieux dégager les cloisonnements

laz_norm <- normalize_height(laz, mnt_tin)
plot(laz_norm)  # Pas de différences visibles mais utilité certaine


# Utilisation de filtre pour espérer dégager les cloisonnements 

laz_filtered <- filter_poi(laz_norm, Z >= 0 & Z <= 0.2)  # points compris entre
# 0 et 20 cm
plot (laz_filtered)  # Les sentiers sont bien visibles mais les cloisonnements 
# ne sont pas bien visible. En améliorant les filtres, des améliorations sont
# possibles

# Création d'un MNT avec le LAS filtré
mnt_filtered <- rasterize_terrain(laz_filtered, 1, tin())
plot(mnt_filtered)

writeRaster(mnt_filtered, "laz_filtered.tif")  # enregistre raster pour QGIS

# Analysis ----

# Exemple d'utilisation de detect.cloiso
cloisonnements <- detect.cloiso(laz_norm)  # bon début mais pas assez performant
# rajout du mnt et du filtre laplacien dans la version finale, ainsi qu'une 
# géométrie polygoniale (plus facilement manipulable sur QGIS) 

# Test de triangulation : objectif trianguler les points qui sont à une certaine 
# hauteur 

x <- laz@data$X  # récupère les valeurs x
y <- laz@data$Y  # récupère les valeurs y 
triangulation <- deldir(x, y)  # erreur : vecteur trop lourd (centaine de Go)

# Test avec laz_filtered 

x_filtered <- laz_filtered@data$X  # récupère les valeurs x
y_filtered <- laz_filtered@data$Y  # récupère les valeurs y 
triangulation_filtered <- deldir(x_filtered, y_filtered)  # trop long
# Trop long pour nos pc 


# Création d'un MNH pour visualiser la hauteur des arbres 

thr <- c(0,2,5,10,20)  # classe les points à différents seuils
edg <- c(0, 1.5)  # valeurs pour les bords
mns <- rasterize_canopy(laz, 1, pitfree(thr, edg))  # créer le MNS
mnt <- rasterize_terrain(laz, 1, tin())  # créer le MNT
plot(mnt)  # visualisation du MNT
plot_dtm3d(mnt)  # visualisation 3D du MNT
test_mnh <- mns-mnt  # créer le MNH
plot(test_mnh)  # visualisation du MNH



