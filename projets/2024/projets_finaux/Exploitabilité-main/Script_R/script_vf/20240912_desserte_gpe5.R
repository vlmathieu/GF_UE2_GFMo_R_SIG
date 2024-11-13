# Projet 5 - Discrimination des surfaces par distance de débardage et par analyses MNT
# Auteur : Killian Baue, Agnès Davière, Louise Dubost, Elda Peronnet (GF, AgroParisTech)
# Contact : agnes.daviere@agroparistech.fr
# Dernière mise à jour : 12 septembre 2024

# Librairies ----
librarian::shelf(happign, terra, tmap, sf, dplyr, raster, leaflet, gpkg)
tmap_mode("view")

# Dossier de travail ----
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Fonctions intermediaires ----

# Récupérer le code insee d'une commune
code.insee <- function(code_post, libelle){
  info_com <- get_apicarto_codes_postaux(code_post)
  ligne <- which(info_com$libelleAcheminement == libelle)
  code_insee <- info_com$codeCommune[[ligne]]
  return(code_insee)
}

# Importer les données cadastrales
importer.cadastre <- function(code_insee, section, num_parc){
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

# Importer les routes
importer.routes <- function(zone_tampon) {
  # importation des troncons de route dans une zone tampon
  get_wfs(zone_tampon,                        # zone tampon pour la requete WFS
          "BDTOPO_V3:troncon_de_route",       
          spatial_filter = "intersects"       
  )  
}

# Re-projeter les donnees spatiales
reprojeter.donnees <- function(donnees,
                               code_crs) {
  st_transform(donnees, crs = code_crs)
}

# Filtrer les routes par type
filtrer.routes <- function(routes) {
  # Creation des sous-ensembles de routes selon leur nature
  routes_grumiers <- routes %>%
    filter(nature %in% c("Route à 1 chaussée", "Route empierrée"))
  
  routes_skidders <- routes %>%
    filter(nature == "Chemin")
  
  routes_sentiers <- routes %>%
    filter(nature == "Sentier")
  
  list(
    routes_grumiers = routes_grumiers,
    routes_skidders = routes_skidders,
    routes_sentiers = routes_sentiers
  )
}

# Verifier l'exploitabilite des pistes
verifier.exploitabilite <- function(routes_skidders,
                                    routes_grumiers,
                                    routes_sentiers,
                                    cadastre_2154) {
  # Creation d'un buffer de 5 m autour des routes grumiers
  buffer_grumiers <- st_buffer(routes_grumiers, dist = 5)
  
  # Verification de la connexion directe entre skidders et grumiers
  connexion_directe <- st_intersects(routes_skidders, buffer_grumiers, sparse = FALSE)
  skidders_connectes <- routes_skidders[rowSums(connexion_directe) > 0, ]
  
  skidders_non_connectes <- routes_skidders[rowSums(connexion_directe) == 0, ]
  
  tous_skidders_exploitables <- skidders_connectes
  
  # Boucle pour trouver les connexions indirectes
  repeat {
    buffer_exploitables <- st_buffer(tous_skidders_exploitables, dist = 5)
    connexion_indirecte <- st_intersects(skidders_non_connectes, buffer_exploitables, sparse = FALSE)
    
    nouveaux_exploitables <- skidders_non_connectes[rowSums(connexion_indirecte) > 0, ]
    
    if (nrow(nouveaux_exploitables) == 0) break
    
    tous_skidders_exploitables <- rbind(tous_skidders_exploitables, nouveaux_exploitables)
    skidders_non_connectes <- skidders_non_connectes[rowSums(connexion_indirecte) == 0, ]
  }
  
  # Intersection entre chemins exploitables et routes grumiers
  intersections <- st_intersection(tous_skidders_exploitables, routes_grumiers)
  if (!inherits(intersections, "POINT")) {
    place_de_depot <- st_collection_extract(intersections, type = "POINT")
  } else {
    place_de_depot <- intersections
  }
  
  # Affichage de la carte des resultats
  carte <- tm_shape(cadastre_2154) +
    tm_borders(col = "black", lwd = 1) +
    tm_shape(routes_grumiers) + 
    tm_lines(col = "blue", lwd = 1.5) +
    tm_shape(tous_skidders_exploitables) + 
    tm_lines(col = "green", lwd = 1) +
    tm_shape(skidders_non_connectes) + 
    tm_lines(col = "red", lwd = 1) +
    tm_shape(routes_sentiers) + 
    tm_lines(col = "#808080", lwd = 1) +
    tm_shape(place_de_depot) + 
    tm_dots(col = "yellow", size = 0.1) + 
    tm_layout(legend.outside = TRUE, legend.position = c("left", "bottom"))
  
  print(carte)
  
  list(
    skidders_exploitables = tous_skidders_exploitables,
    skidders_non_exploitables = skidders_non_connectes,
    place_de_depot = place_de_depot
  )
}

# Sauvegarder une couche vecteur dans un fichier geopackage
sauvegarder.couche <- function(donnees, chemin_fichier, nom_couche) {
  # Ecriture de la couche dans un geopackage
  st_write(donnees, chemin_fichier, layer = nom_couche, delete_layer = TRUE)
}

# Créer des zones buffers autour de la desserte
zone.buffer <- function(
    shape_routes, 
    dist_1, 
    dist_2, 
    dist_3) {
  
  # Suppression des colonnes avec des valeurs NA
  shape_routes_clean <- shape_routes[, colSums(is.na(shape_routes)) == 0]
  
  # Vérifier si les géométries sont valides, sinon les corriger
  shape_routes_clean <- st_make_valid(
    shape_routes_clean)
  
  # Créer des buffers autour des routes avec les distances spécifiées
  buffer_1 <- st_buffer(
    shape_routes_clean, 
    dist = dist_1)
  buffer_2 <- st_buffer(
    shape_routes_clean, 
    dist = dist_2)
  buffer_3 <- st_buffer(
    shape_routes_clean, 
    dist = dist_3)
  
  # Ajouter une colonne "distance" pour identifier chaque zone
  buffer_1$distance <- dist_1
  buffer_2$distance <- dist_2
  buffer_3$distance <- dist_3
  
  # Fusionner les buffers
  buffer_merged <- rbind(
    buffer_1, 
    buffer_2, 
    buffer_3)
  
  # Retourner l'objet avec les buffers fusionnés
  return(buffer_merged)
}

# Générer un raster à partir d'un buffer avec nrows et ncols en entrée
raster.buffer <- function(
    buffer, 
    resolution = 25, 
    crs = "EPSG:2154", 
    nrows = 300, 
    ncols = 300) {
  # Déterminer l'étendue (extent) du buffer
  extent_shape <- ext(
    st_bbox(buffer))
  
  # Créer un raster basé sur cette étendue, la résolution, nrows, ncols, et la projection spécifiée
  r <- rast(
    nrows = nrows, 
    ncols = ncols, 
    res = resolution, 
    crs = crs, 
    extent = extent_shape)
  
  # Rasteriser le buffer en utilisant la colonne 'distance'
  buffer_raster <- terra::rasterize(
    x = buffer, 
    y = r, 
    field = 'distance', 
    fun = min)
  
  # Retourner le raster généré
  return(buffer_raster)
}

# Visualiser un raster avec des chemins de desserte superposés
visualiser.raster.desserte <- function(buffer_raster, shape_routes, colors = c("green", "yellow", "orange"), title = "Buffers autour de la desserte") {
  # Ajuster les marges et permettre des éléments en dehors de la zone de tracé
  par(xpd = TRUE, mar = c(1, 1, 1, 1))
  
  # Tracer le raster fusionné avec les couleurs définies
  plot(buffer_raster, 
       main = title,        # Titre du graphique
       col = colors,        # Appliquer les couleurs définies pour chaque distance
       legend = TRUE,       # Afficher la légende
       axes = TRUE,         # Afficher les axes
       box = TRUE,          # Encadrer le tracé
       xpd = TRUE)          # Permettre les éléments hors de la zone de tracé
  
  # Ajouter les chemins de desserte superposés sur le raster
  plot(st_geometry(shape_routes), 
       add = TRUE, 
       col = "blue",        # Couleur des chemins de desserte
       lwd = 1)             # Largeur de ligne pour les chemins
}

#Recupérer le MNT associé a la zone d'étude
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

# Calculer la pente à partir du MNT
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

# Visualiser à la fois un raster et un vecteur 
draw <- function(raster,vecteur){
  tm_shape(raster)+
    tm_raster()+
    tm_shape(vecteur)+
    tm_borders("black", lwd = 2)
}

# Enregistrer un raster en geopackage
save.raster.gpkg <- function(SpatRaster) {
  layer_name <- names(SpatRaster)
  writeRaster(SpatRaster,
              filename = "projet5.gpkg",
              filetype = "GPKG",
              gdal = c("APPEND_SUBDATASET=YES",
                       paste0("RASTER_TABLE=", layer_name))
  )
}

# Enregistrer un vecteur en geopackage
save.sf.gpkg <- function(sf) {
  gpkg_path <- paste0(dirname(rstudioapi::getActiveDocumentContext()$path),"./projet5.gpkg")
  layer_name <- deparse(substitute(sf))
  st_write(sf,
           gpkg_path,
           layer = layer_name,
           append = TRUE
  )
}

# Enregistrer un raster et un vecteur en geopackage
save.gpkg <- function(SpatRaster, sf){
  save.raster.gpkg(SpatRaster)
  save.sf.gpkg(sf)
}

# Fonctions principales ----
# Obtenir la desserte et les buffer autour de la desserte
obtention.desserte <- function(code_post, libelle, section, num_parc) {
  # Importation et reprojection des donnees cadastrales
  code_insee <- code.insee(code_post, libelle)
  cadastre <- importer.cadastre(code_insee, section, num_parc)
  cadastre_2154 <- reprojeter.donnees(cadastre, 2154)
  
  # Creation d'une zone tampon autour des parcelles cadastrales
  zone_tampon <- st_buffer(cadastre_2154, dist = 1000)
  
  # importation des routes intersectant la zone tampon
  routes <- importer.routes(zone_tampon)
  routes_2154 <- reprojeter.donnees(routes, 2154)
  
  # Filtrage des routes par type
  routes_filtrees <- filtrer.routes(routes_2154)
  
  # Verification de l'exploitabilite des pistes
  resultats_exploitabilite <- verifier.exploitabilite(
    routes_filtrees$routes_skidders,
    routes_filtrees$routes_grumiers,
    routes_filtrees$routes_sentiers,
    cadastre_2154
  )
  
  # Sauvegarde des resultats dans un fichier geopackage
  chemin_gpkg <- "exploitabilite_desserte.gpkg"
  couches_a_sauvegarder <- list(
    "cadastre" = cadastre_2154,
    "troncons_routes" = routes_2154,
    "sentiers" = routes_filtrees$routes_sentiers,
    "routes_grumiers" = routes_filtrees$routes_grumiers,
    "chemins_exploitables" = resultats_exploitabilite$skidders_exploitables,
    "chemins_non_exploitables" = resultats_exploitabilite$skidders_non_exploitables,
    "place_de_depot" = resultats_exploitabilite$place_de_depot
  )
  
  # Sauvegarde de chaque couche dans le geopackage
  for (nom_couche in names(couches_a_sauvegarder)) {
    sauvegarder.couche(couches_a_sauvegarder[[nom_couche]], chemin_gpkg, nom_couche)
  }
  
  print("Toutes les couches ont ete sauvegardees dans le fichier GeoPackage.")
}
get.buffer <- function(){
  geopackage_file <- paste0((dirname(rstudioapi::getActiveDocumentContext()$path)),"/exploitabilite_desserte.gpkg")
  shape_route_path <- sf::st_read(geopackage_file, layer = "chemins_exploitables")
  shape_route_path$type <-"chemins_exploitables"
  shape_route_path_2 <- sf::st_read(geopackage_file, layer = "routes_grumiers")
  shape_route_path_2$type <- "routes_grumiers"
  
  merged_shape <- rbind(
    shape_route_path, 
    shape_route_path_2)
  str(merged_shape$geom)
  
  # Création des buffers 
  buffer_desserte_vect <- zone.buffer(merged_shape, 100, 200, 500) 
  
  # Générer le raster de desserte
  buffer_desserte_rast <- raster.buffer(
    buffer_desserte_vect, 
    resolution = 25, 
    crs = "EPSG:2154", 
    nrows = 300, 
    ncols = 300)
  
  # Enregistrer les fichiers dans un geoPackage
  save.gpkg(buffer_desserte_rast, buffer_desserte_vect)
  
  # Visualisation du raster avec les chemins de desserte
  carte_desserte <- visualiser.raster.desserte(
    buffer_desserte_rast, 
    merged_shape)
  
}

get.desserte <- function(code_post, libelle, section, num_parc){
  desserte <- obtention.desserte(code_post, libelle, section, num_parc)
  buffer <- get.buffer()
}

# Obtenir la pente
get.slope <- function(code_post, libelle, section, num_parc){
  code_insee <- code.insee(code_post, libelle)
  zone_parca <- importer.cadastre(code_insee, section, num_parc)
  mnt <- get.mnt(zone_parca)
  pente <- calculate.slope(mnt)
  save.gpkg(pente, zone_parca)
}

# Exemple  ----

code_post = "74420"
libelle <- "SAXEL"
section <- list(NULL)
num_parc <- list(NULL)

get.desserte(code_post, libelle, section, num_parc)














