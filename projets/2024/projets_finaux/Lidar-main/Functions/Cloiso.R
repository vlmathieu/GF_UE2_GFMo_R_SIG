library(happign)
library(sf)  # for vector
library(tmap); tmap_mode("view")  # Set map to interactive
library(dplyr)
library(ggplot2);sf_use_s2(FALSE)  # Avoid problem with spherical geometry
library(purrr)
library(stars)
library(terra)  # for raster
library(jsonlite)  # to manipulate .json
library(lidR)
library(spatialEco)


detect.cloiso <- function(laz, resolution = 1, threshold = 0.1, output_file = "cloisonnements.gpkg") {
  if (is.null(laz) || npoints(laz) == 0) {
    stop("Le fichier LAZ est vide ou n'a pas été chargé correctement.")
  }
  
  # Calculer le nombre de retours
  returns <- grid_metrics(laz, ~length(Z), res = resolution / 2)
  names(returns) <- "num_returns"
  
  # MNH/mnt (Modèle Numérique de Hauteur)
  mnt1 = grid_terrain(laz, res = resolution / 2, algorithm = tin())
  laplacian_kernel <- matrix(c(1, 1, 1,
                               1, -8, 1,
                               1, 1, 1), 
                             nrow = 3, ncol = 3)
  
  # Appliquer le filtre Laplacien au raster
  mnt_sqrt <- focal(mnt1, w = laplacian_kernel, fun = sum, na.policy = "omit", pad = TRUE)
  names(mnt_sqrt) <- "mnt"
  norm = normalize_height(laz, mnt1)
  mnh <- grid_canopy(norm, res = resolution / 2, algorithm = pitfree())
  names(mnh) <- "mnh_height"
  
  
  # Empiler les rasters pour les combiner
  combined_stack <- raster::stack(returns, mnh, mnt_sqrt)
  
  # Convertir en data frame pour traitement
  combined_df <- as.data.frame(combined_stack, xy = TRUE)
  combined_df <- na.omit(combined_df)
  
  # Détecter les zones à faible densité, faible nombre de retours et faible hauteur
  combined_df$low_returns <- ifelse(combined_df$num_returns < 6, 1, 0)
  combined_df$low_mnh <- ifelse(combined_df$mnh_height < 3, 1, 0)
  combined_df$low_mnt = ifelse(combined_df$mnt < quantile(combined_df$mnt, threshold, na.rm = TRUE), 1, 0)
 
  # Détecter les cloisonnements avec une pondération
  combined_df$cloisonnement <- with(combined_df, (low_returns * 0.33 + low_mnh * 0.33 + low_mnt * 0.33) > 0.65)
  
  # Filtrer les zones de cloisonnements
  cloisonnements_points <- combined_df[combined_df$cloisonnement, ]
  
  if (nrow(cloisonnements_points) > 0) {
    # Convertir en objet spatial
    cloisonnements_sf <- st_as_sf(cloisonnements_points, coords = c("x", "y"), crs = st_crs(laz))
    
    # Appliquer un buffer et dissoudre pour connecter les points proches
    cloisonnements_buffer <- st_buffer(cloisonnements_sf, dist = resolution)
    cloisonnements_dissolved <- st_union(cloisonnements_buffer)
    
    # Simplifier les lignes pour réduire le bruit
    centerlines_simplified <- st_simplify(cloisonnements_dissolved, dTolerance = resolution / 2)
    
    # Lisser les lignes pour un résultat plus naturel
    cloisonnements_smooth <- st_simplify(centerlines_simplified, dTolerance = resolution / 4)
    
    # Exporter au format GPKG
    st_write(cloisonnements_smooth, output_file, driver = "GPKG", delete_layer = TRUE)
    message("Cloisonnements exportés vers ", output_file)
    
    return(cloisonnements_smooth)
  } else {
    message("Aucun cloisonnement détecté.")
    return(NULL)
  }
}
