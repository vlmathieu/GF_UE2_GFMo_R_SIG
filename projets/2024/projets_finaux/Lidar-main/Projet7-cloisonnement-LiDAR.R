# About this code ----

# Projet pédagogique sur l'utilisation des données LIDAR récentes pour retrouver
# les cloisonnements sur un peuplement

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

# Librairies ----

library(sf)  # for vector
library(tmap); tmap_mode("view")  # Set map to interactive
library(dplyr)  # manipulating data
library(ggplot2);sf_use_s2(FALSE)  # Avoid problem with spherical geometry
library(purrr)  # for function facilitation 
library(stars)  # for spatial object
library(terra)  # for raster
library(jsonlite)  # to manipulate .json
library(lidR)  # for LiDAR data

# Set working directory ----

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))  # créer chemin 
dir <- getwd()

# Fonctions ----

# Création d'une fonction pour séléctionner une zonne d'étude.
draw.area <- function(){
  # permet de définir une zone d'étude en Lambert93
  zone = st_coordinates(st_transform(mapedit::drawFeatures(), crs = 2154))
  # détermine les valeurs min et max du rectangle dessiné
  y1 = min(zone[, 2])
  x1 = min(zone[, 1])
  y2 = max(zone[, 2])
  x2 = max(zone[, 1])
  return(c(x1,y1,x2,y2))
}

# Création d'une fonction pour télécharger les données LiDAR. 
download.lidar <- function(x1, y1, x2, y2) {
  # Créer une séquence de coordonnées avec un pas de 10000 (pas du LiDAR) à 
  # à partir des coordonnées définies précédemment dans la fonction draw.area
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
                        # le nom correspond aux coordonnées x et y 
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
cut.area <- function(laz, liste){  # créer une liste avec les coordonnées 
  clip = clip_rectangle(laz, liste[1], liste[2], liste[3], liste[4])
  return(clip)
}

# Création d'une fonction pour détecter automatiquement les cloisonnements.
detect.cloiso <- function(laz, output_file, resolution = 1, threshold = 0.1) {
  # on peut modifier le seuil de détection (par rapport aux quantiles, ici 0.1)
  # vérification du fichier .laz
  if (is.null(laz) || npoints(laz) == 0) {
    stop("Le fichier LAZ est vide ou n'a pas été chargé correctement.")
  }
  
  # Calculer le nombre de retours
  returns <- grid_metrics(laz, ~length(Z), res = resolution / 2)
  names(returns) <- "num_returns"
  
  # MNT avec l'algorithme tin (Modèle Numérique de Terrain)
  mnt1 = grid_terrain(laz, res = resolution / 2, algorithm = tin())
  # Création d'un filtre laplacien pour détecter les changements brusques 
  laplacian_kernel <- matrix(c(1, 1, 1,
                               1, -8, 1,
                               1, 1, 1), 
                             nrow = 3, ncol = 3)
  
  # Appliquer le filtre Laplacien au raster
  mnt_sqrt <- focal(mnt1, w = laplacian_kernel, fun = sum, na.policy = "omit", 
                    pad = TRUE)
  names(mnt_sqrt) <- "mnt"
  norm = normalize_height(laz, mnt1)
  
  # Création d'un MNH (modèle numérique de hauteur)
  mnh <- grid_canopy(norm, res = resolution / 2, algorithm = pitfree())
  names(mnh) <- "mnh_height"
  
  # Empiler les rasters pour les combiner
  combined_stack <- raster::stack(returns, mnh, mnt_sqrt)
  
  # Convertir en dataframe pour le traitement 
  combined_df <- as.data.frame(combined_stack, xy = TRUE)
  
  # Supprime les NA
  combined_df <- na.omit(combined_df)
  
  # Détecter les zones à faible densité, faible nombre de retours et hauteur
  # Les seuils peuvent être modifiés manuellement 
  combined_df$low_returns <- ifelse(combined_df$num_returns < 6, 1, 0)
  combined_df$low_mnh <- ifelse(combined_df$mnh_height < 3, 1, 0)
  combined_df$low_mnt <- ifelse(combined_df$mnt < quantile(combined_df$mnt,
                                                threshold, na.rm = TRUE), 1, 0)
  
  # Détecter les cloisonnements avec une pondération
  combined_df$cloisonnement <- with(combined_df,
                  (low_returns * 0.33 + low_mnh * 0.33 + low_mnt * 0.33) > 0.65)
  
  # Filtrer les zones de cloisonnements
  cloisonnements_points <- combined_df[combined_df$cloisonnement, ]
  
  if (nrow(cloisonnements_points) > 0) {
    # Convertir en objet spatial
    cloisonnements_sf <- st_as_sf(cloisonnements_points, coords = c("x", "y"), 
                                  crs = st_crs(laz))
    
    # Appliquer un buffer et fusionne les géométries proches
    cloisonnements_buffer <- st_buffer(cloisonnements_sf, dist = resolution)
    cloisonnements_dissolved <- st_union(cloisonnements_buffer)
    
    # Simplifier les lignes pour réduire le bruit
    centerlines_simplified <- st_simplify(cloisonnements_dissolved,
                                          dTolerance = resolution / 2)
    
    # Lisser les lignes pour un résultat plus naturel
    cloisonnements_smooth <- st_simplify(centerlines_simplified,
                                         dTolerance = resolution / 4)
    
    # Exporter au format GPKG
    st_write(cloisonnements_smooth, output_file, driver = "GPKG",
             delete_layer = TRUE)
    message("Cloisonnements exportés vers ", output_file)
    
    return(cloisonnements_smooth)
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
                      pattern= '.laz')  # Liste les fichiers .laz du directory 

# Analysis data ----

compteur = 0  # création d'un compteur dans le cas ou plusieurs fichier .laz
# sont présents dans le directory

for(files in laz_dir){  # début de la boucle générale pour détecter les cloisos
  compteur = compteur + 1  # début du compteur
  laz <- readLAS(files)  # lecture des fichiers .laz
  laz <- cut.area(laz, coord)  # découpe la zone correspondant aux coordonnées
  cloiso = detect.cloiso(laz, paste0("cloiso",commpteur,".gpkg"))  # applique 
  # la fonction detect.cloiso aux différents fichiers .laz
}
