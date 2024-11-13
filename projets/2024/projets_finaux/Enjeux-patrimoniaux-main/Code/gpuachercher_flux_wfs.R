# A propos du document ----
# Date : 6 septembre 2024
# Autrice : Adele Desaint 
# Objectif : Ce code a pour objectif de recuperer les données des SUP
# a partir du serveur du geoportail de l'urbanisme

# Packages
library(librarian)
shelf(sf, httr,happign,dplyr,tmap)
library(tmap);ttm()

# x est un code INSEE
# Exemple : 05023, Briançon

get.sup <- function(x){
  
  # Recuperation des SUP
  wfs_url <- "https://data.geopf.fr/wfs/ows?SERVICE=WFS&VERSION=1.1.0&REQUEST=GetCapabilities"
  SUP_s <- st_read(wfs_url, layer = "wfs_sup:assiette_sup_s") 
  SUP_s <- st_transform(SUP_s, 2154)
  
  # Selection des SUP utiles 
  SUP_s <- SUP_s[
    SUP_s$suptype == "ac1"|   # monuments historiques
      SUP_s$suptype == "ac4"|   # patrimoine architectural
      SUP_s$suptype == "ac2",]   # sites inscrits et classes
  
  # Separation des geometries valides et invalides
  valid_SUP_s <- SUP_s[st_is_valid(SUP_s$the_geom) == T, ]
  invalid_SUP_s <- SUP_s[!st_is_valid(SUP_s$the_geom) == T,]
  
  # Recherche des SUP dans la commune consideree
  point <- get_apicarto_cadastre(x, type = "commune")
  point <- st_transform(point, 2154)
  
  SUP_s_point <- valid_SUP_s[st_intersection(valid_SUP_s$the_geom,point),]
  
  # Si la geometrie est invalide, on cherche le code INSEE dans les SUP
  SUP_commune <- grep(x, invalid_SUP_s$partition) 
  
  departement <- substring(x,1,2)
  SUP_departement <- grep("_'departement'_", invalid_SUP_s$partition)
  
  return(list(SUP_s_point, SUP_commune, SUP_departement))
  
}

# Exemple 
resultat <- get.sup(x)
qtm(resultat[[1]])
```