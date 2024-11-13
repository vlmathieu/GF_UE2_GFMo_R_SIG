# A propos du code -----

# Titre du code : gpuachercher_documents_urbanisme
# But du code : Récupération des partitions et identifiants des documents d'urbanisme 
# à partir d'une zone d'étude.
# Auteurs : Ninon Delattre, Adèle Desaint, Sylvain Giraudo, Cyril Guillaumant, Louise Rovel
# Contact : sylvain.giraudo13@gmail.com
# Dernière mise à jour : 12/09/2024

# Installation des Packages ----

# Ce code necessite l'installation des packages rstudioapi et librarian

# Installation et chargement des packages
librarian::shelf(happign,dplyr,sf,tidyverse,tmap)

tmap_mode("view"); tmap_options(check.and.fix = TRUE)

# Repertoire de travail -----

# Repertoire de travail relatif a la source du fichier 
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Nettoyage de l'environnement R ----
rm(list=ls())



# fonction pour obtenir les codes insee des communes associees a une geometrie ----
get.code.insee <- function(shp){
  if (inherits(shp, c("sf", "sfc"))) {
    communes <- get_apicarto_gpu(shp,"municipality")
    code_insee <- communes$insee
  } else {
    stop("x must be of class sf or sfc.")
  }
  return(code_insee)
}

# Fonction pour décrire quels sont les documents d'urbanisme present dans les communes ----
insee.to.documents <- function(code_insee){
  
  if(!inherits(code_insee,"character")){
    stop("x must be of class character")
  }
  
  # Y a-t-il un rnu associé à ces codes insee ?
  is_rnu <- get_apicarto_gpu(code_insee, ressource = "municipality")
  
  # Séparation des municipalités avec et sans rnu
  is_rnu_TRUE <- filter(is_rnu, is_rnu == TRUE)
  is_rnu_FALSE <- filter(is_rnu, is_rnu == FALSE)
  
  # Affichage des communes présentes avec ou sans rnu
  cat("\nCommunes with rnu are:\n")
  print(is_rnu_TRUE$name)
  
  cat("\nCommunes without rnu are:\n")
  print(is_rnu_FALSE$name)
  
  # Creation de dataframe conenant les documents d'urbanismes 
  doc_urbanisme <- data.frame(grid_title = character(),
                              partition = character(),
                              du_type = character(),
                              stringsAsFactors = FALSE)
  
  # Parcours de des comunnes non soumises au rnu
  for (i in 1:nrow(is_rnu_FALSE)) {
    
    row <- is_rnu_FALSE[i,]
    doc <- get_apicarto_gpu(row, "document", dTolerance = 10)  # chargement des documents de la commune
    
    if (is.null(doc)) {
      next
    }
    
    doc_filtered <- doc |> 
      filter(grid_title == row$name) # extraction des documents spécifiques à la commune (PLU, PSMV, CC)
    
    # Si aucuns documents associes a la commune, 
    # extraction du PLUi s'il existe
    if (nrow(doc_filtered) == 0) {
      doc_filtered <- doc |>
        filter(du_type == "PLUi")
    }
    
    # Si toujours pas de résultats, afficher un avertissement
    if (nrow(doc_filtered) == 0) {
      warning(paste("No document found for", row$name))
      next
    }
    
    # Ajout des documents filtrees au dataframe
    doc_urbanisme <- rbind(doc_urbanisme, 
                           doc_filtered)
  }
  
  # suppression des dupplicats (par exemple si plusieurs fois le meme PLUi)
  doc_urbanisme_unique <- doc_urbanisme[!duplicated(doc_urbanisme), ]
  
  # Affichage des partitions de documents d'urbanisme associes aux communes.
  cat("\nThe following town planning documents exist in the surrounding municipalities:\n")
  print (as.data.frame(doc_urbanisme_unique)[,c("grid_title", "partition", "du_type")])
  
  return(doc_urbanisme_unique)
}

# Exemple

# area <- mapedit::drawFeatures()
# 
# resultats <- insee.to.documents(get.code.insee(area))
# 
# resultats <- insee.to.documents("56031")






