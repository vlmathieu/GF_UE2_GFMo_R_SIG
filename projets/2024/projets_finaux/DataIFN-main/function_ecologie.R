# Fichier des fonctions lié à l'écologie des placettes ----


# Fonction d'importation de la zone d'étude ----
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


# Fonction obtention buffer et placette à l'intérieur ----
get_buffer_zone <- function(buffer = 0){
  
  # Création de la zone tampon autour du shapefile
  zone_tampon <<- st_buffer(shp_etude, dist = buffer)
  
  # Selection des placettes uniquement dans la zone tampon
  placette_tampon <<- st_intersection(placette, zone_tampon)
  
  # Obtenir les limites combinées de toutes les couches pour ajuster le zoom
  all_bounds <<- st_bbox(st_union(st_geometry(shp_etude),
                                  st_geometry(zone_tampon),
                                  st_geometry(placette_tampon)))
  
  # Extraire les IDP des placettes dans la zone tampon
  idp_placette_tampon <- placette_tampon$IDP
  
  # Filtre les arbres ayant le même IDP que les placettes de la zone
  arbre_zone_etude <<- arbre[arbre$IDP %in% idp_placette_tampon, ]
  
  
  # Convertir l'objet dessiné en sf si nécessaire
  shp_etude <- st_as_sf(shp_etude)
  
  # Vérifier si la conversion a bien fonctionné
  if (is.null(shp_etude)) {
    stop("Erreur lors de la conversion en objet sf.")
  }
  # Assurez-vous que les coordonnées sont correctement transformées
  # Les données placette IFN étant en lambert 93 (2154)
  shp_etude <<- st_transform(shp_etude, 2154)
  
  return(shp_etude)
}


# Fonction d'affichage des cartes avec placettes----
get_read_map <- function(){
  # Passer en mode interactif avec tmap
  tmap_mode("view")
  
  # Choisir le CRS de la zone d'étude
  common_crs <- st_crs(shp_etude)  
  zone_tampon <- st_transform(zone_tampon, common_crs)
  placette_tampon <- st_transform(placette_tampon, common_crs)
  
  
   #Calculer le nombre de placettes et d'arbres dans la zone tampon
  nombre_placettes <- nrow(placette_tampon)  # Nombre de placettes dans la zone tampon
  nombre_arbres <- nrow(arbre_zone_etude)  # Nombre d'arbres dans la zone tampon
  
  titre <- paste("Placettes dans la zone",
                 "\nNombre de placettes :", nombre_placettes,
                 "\nNombre d'arbres :", nombre_arbres)
  
  # Afficher la carte avec tmap et ajuster le zoom sur toutes les couches
  plot_zone <<- tm_shape(shp_etude, bbox = all_bounds) +  # Zone d'étude originale avec ajustement des limites
    tm_fill(col = "lightgreen", alpha = 0.3) +  # Remplissage vert avec transparence
    tm_borders(col = "black") +  # Contour noir
    tm_shape(zone_tampon) +  # Zone tampon
    tm_borders(col = "blue", lty = "dashed") +  # Ligne bleue en pointillé
    tm_shape(placette_tampon) +  # Placettes dans la zone tampon
    tm_symbols(col = "red", size = 0.005) +  # Placettes en rouge
    tm_layout(main.title = titre,
              main.title.size = 1,
              frame = TRUE)  # Ajouter un titre, sans cadre
  return(plot_zone)
}


# fonction filtre des placettes----
get_pla_eco <- function(){
  placette_etude_eco <<- ecologie %>%
    select(IDP, TOPO, OBSTOPO, HUMUS, OLT, TSOL, TEXT1, ROCHE, OBSRIV2, 
           DISTRIV, DENIVRIV, OBSVEGET, OBSDATE )
  placette_etude_eco <<- placette_etude_eco [placette_etude_eco$IDP %in% placette_tampon$IDP,]
  return(placette_etude_eco)
}



# Proportion des différents paramètres ----
get_proportion_eco <- function(){
  proportions_humus <<- placette_etude_eco %>%
    count(HUMUS) %>%
    mutate(proportion_des_humus = n*100 / sum(n))
  proportions_TSOL <<- placette_etude_eco %>%
    count(TSOL) %>%
    mutate(proportion_des_types_de_sol = n*100 / sum(n))
  proportions_TEXT1 <<- placette_etude_eco %>%
    count(TEXT1) %>%
    mutate(proportion_des_textures_de_sol = n*100 / sum(n))
  proportions_ROCHE <<- placette_etude_eco %>%
    count(ROCHE) %>%
    mutate(proportion_des_types_de_roche_mère = n*100 / sum(n))
}


# fonction proportion des différents paramètre du sol
get_data_value <- function(){
  placette_etude_eco_value <<- data_frame()
  placette_etude_eco_value <<- placette_etude_eco$IDP
  
  #récupérer les codes
  # Créer des data frames vides avec les colonnes appropriées
  code_HUMUS <<- data.frame(HUMUS = character())
  code_TSOL <<- data.frame(TSOL = character())
  code_TEXT1 <<- data.frame(TEXT1 = character())
  code_ROCHE <<- data.frame(ROCHE = character())
  
  
  # Remplir les data frames avec les valeurs de placette_etude_eco
  for (i in 1:nrow(placette_etude_eco)){
    code_HUMUS <<- rbind(code_HUMUS, 
                        data.frame(HUMUS = placette_etude_eco$HUMUS[i]))
    code_TSOL <<- rbind(code_TSOL, 
                       data.frame(TSOL = placette_etude_eco$TSOL[i]))
    code_TEXT1 <<- rbind(code_TEXT1, 
                        data.frame(TEXT1 = placette_etude_eco$TEXT1[i]))
    code_ROCHE <<- rbind(code_ROCHE, 
                        data.frame(ROCHE = placette_etude_eco$ROCHE[i]))
  }
  #réalisation des data frame pour chaque codes avec les libellées
  
  code_HUMUS_lib <<- data.frame(HUMUS = character())
  code_HUMUS_lib <<- units_value_set %>%
    filter(units == "HUMUS") %>%
    mutate(units = "HUMUS")
  
  code_TSOL_lib <<- data.frame(TSOL = character())
  code_TSOL_lib <<- units_value_set %>%
    filter(units == "TSOL") %>%
    mutate(units = "TSOL")
  
  code_TEXT1_lib <<- data.frame(TEXT1 = character())
  code_TEXT1_lib <<- units_value_set %>%
    filter(units == "TEXT1") %>%
    mutate(units = "TEXT1")
  
  code_ROCHE_lib <<- data.frame(ROCHE = character())
  code_ROCHE_lib <<- units_value_set %>%
    filter(units == "ROCHED0") %>%
    mutate(units = "ROCHED0")

  
  proportions_humus <<- proportions_humus %>%
    mutate(HUMUS = as.character(HUMUS)) # Convertir HUMUS en character
  proportions_humus <<- proportions_humus %>%
    left_join(code_HUMUS_lib, by = c("HUMUS" = "code"))
  proportions_humus <<- proportions_humus %>%
    select(-units)
  
  proportions_TSOL <<- proportions_TSOL %>%
    mutate(TSOL = as.character(TSOL)) # Convertir HUMUS en character
  proportions_TSOL <<- proportions_TSOL %>%
    left_join(code_TSOL_lib, by = c("TSOL" = "code"))
  proportions_TSOL <<- proportions_TSOL %>%
    select(-units)
  
  proportions_TEXT1 <<- proportions_TEXT1 %>%
    mutate(TEXT1 = as.character(TEXT1)) # Convertir TEXT1 en character
  proportions_TEXT1 <<- proportions_TEXT1 %>%
    left_join(code_TEXT1_lib, by = c("TEXT1" = "code"))
  proportions_TEXT1 <<- proportions_TEXT1 %>%
    select(-units)
  
  proportions_ROCHE <<- proportions_ROCHE %>%
    mutate(ROCHE = as.character(ROCHE)) # Convertir ROCHE en character
  proportions_ROCHE <<- proportions_ROCHE %>%
    left_join(code_ROCHE_lib, by = c("ROCHE" = "code"))
  proportions_ROCHE <<- proportions_ROCHE %>%
    select(-units)
  
  return()
}


#création des groupes de flores

get_groupe_flore <- function(){
  #création du groupe des hygrophyles
  hygrophyle <<- flore %>%
    filter(CD_REF %in% c(923000, 88318, 88493, 88833, 99494, 103772, 137541,
                         107090, 108027, 122069))
  Mesohygrophile <<- flore %>%
    filter(CD_REF %in% c(159536, 88766, 88819, 88893, 91378, 98717, 103031, 
                         107073, 139023, 117201, 142070))
  Acidicline <<- flore %>% # Acidiclines à acidiphiles sur sols à nappe temporaire 
    filter(CD_REF %in% c(86101, 88395, 88747, 788967, 108718, 197825, 6747,
                         6748, 6769, 6789))
  Neutronitrophiles <<- flore %>%
    filter(CD_REF %in% c(80243, 80322, 81295, 81541, 84112, 87964, 99373, 
                         100142, 100225, 100310, 135306, 108361, 112421, 
                         4946, 139364, 98651, 134666, 117774, 120717, 124814, 128268))
  Neutronitroclines <<- flore %>% #Espèces des milieux neutres assez riches
    filter(CD_REF %in% c(80990, 82637, 718321, 132818, 95567, 134348, 99488, 
                         104876, 107880, 113407, 114611, 116142, 129305))
  Acidicline <<- flore %>% 
    filter(CD_REF %in% c(3853, 613147, 99334, 106854, 108537, 114153, 125006, 
                         128938))
  Acidicline_hygrocline <<- flore %>%
    filter(CD_REF %in% c(84999, 91258, 133787, 95558, 95563, 107072, 111859, 
                         122028, 128924))
  Acidiphile <<- flore %>%
    filter(CD_REF %in% c(132790, 136654, 103320, 137432, 613135, 137522, 3865,
                         116265, 126035))
  Hyperacidiphile <<- flore %>%
    filter(CD_REF %in% c(87501, 718314, 4754, 4770, 128345))
  Calcicline <<- flore %>%
    filter( CD_REF %in% c(86305, 132529, 132707, 92497, 133432, 94435, 609982, 
                          105966, 106595, 611652, 129083))
  return()
}
  
#création des tableaux pour chaque placette avec les plantouze et les 
#caractéristiques du sol

get_data_idp <- function(){
  placette_sol_flore <<- left_join(placette_etude_eco, flore, by = "IDP")
  
  #dénombrer pour chaque placettes le nombre de plante appartenant à chaque groupe
  liste_groupe_eco <<- list(hygrophyle = hygrophyle,
                           Calcicline = Calcicline,
                           Hyperacidiphile = Hyperacidiphile,
                           Acidiphile = Acidiphile,
                           Acidicline_hygrocline = Acidicline_hygrocline,
                           Acidicline = Acidicline,
                           Neutronitroclines = Neutronitroclines,
                           Neutronitrophiles = Neutronitrophiles,
                           Mesohygrophile = Mesohygrophile)
  
  # Initialisation du tableau final avec juste les IDP pour commencer
  resultats_groupes <<- data.frame(IDP = unique(placette_sol_flore$IDP))


  # Boucle sur chaque groupe écologique pour ajouter le nombre total de plantes par placette
  for (groupe in names(liste_groupe_eco)) {
    df_indicateur <<- liste_groupe_eco[[groupe]]
    
    # Jointure avec placette_sol_flore pour obtenir les plantes du groupe écologique sur chaque placette
    groupe_plantes <<- placette_sol_flore %>%
      inner_join(df_indicateur, by = c("IDP", "CD_REF")) %>% # Assurez-vous que la colonne de référence est la bonne (IDP et CD_REF)
      group_by(IDP) %>%
      summarise(ABOND_total = sum(ABOND.y, na.rm = TRUE)) %>%
      rename(!!paste0("ABOND_", groupe) := ABOND_total) # Renommer dynamiquement la colonne selon le groupe
    
    # Joindre les résultats pour chaque groupe dans le tableau final
    resultats_groupes <<- left_join(resultats_groupes, groupe_plantes, by = "IDP")
  placette_etude_eco <<- left_join(placette_etude_eco, resultats_groupes, by = "IDP")
  return(placette_etude_eco)
  }
}
  



#création d'un filtre 
filtre_peuplement <- function(){
  #filtre en fonction de la sylvoécorégion
  data("ser")
  sylvocoecoregion <<- readline(prompt = paste("Voulez vous choisir une sylvoécorégion.", 
                                             "Si oui écrire le nom de la syvoécorégion", 
                                             "si non écrire non: "))
  if (sylvocoecoregion != "non") {
    sylveco_F <<- ser %>%
      filter(ser[["NomSER"]] == sylvocoecoregion)
    placette_ecoregion <<- placette_etude_eco
  
    placette_ecoregion <<- placette_ecoregion %>%
      left_join(placette_tampon %>% select(IDP,SER), by = "IDP") 
  
    placette_ecoregion <<- placette_ecoregion%>%
      rename(codeser = SER)
    
    placette_ecoregion <<- placette_ecoregion %>%
      left_join(ser, by = "codeser")
  
    placette_ecoregion <<- placette_ecoregion %>%
      filter(placette_ecoregion[["NomSER"]] == sylvocoecoregion)
  }
  else {placette_ecoregion <<- placette_etude_eco}
  
  
  # filtre en fonction de la topo
  V_topo <<- readline(prompt = paste("Entrez la valeur pour filtrer la topologie (si pas de filtre necessaire écrire non): "))
  if (V_topo != "non") {
    placette_ecoregion_F <<- placette_ecoregion
    placette_ecoregion_F <<- placette_etude_eco %>%
      filter(placette_etude_eco[["TOPO"]] == V_topo)
  }
  else{placette_ecoregion_F <<- placette_ecoregion}
  
  
  
  #filtre pour le tyoe de peuplement CD_HAB
  habitat_col <<- habitat %>%
    select("IDP","CD_HAB")
  placette_ecoregion_F <<- placette_ecoregion_F %>%
    left_join(habitat_col , by = "IDP")
  V_peu <<- readline(prompt = paste("Entrez la valeur du code de peuplement (si pas de filtre necessaire écrire non): "))

  if (V_peu != "non") {
    placette_ecoregion_F <<- placette_ecoregion_F %>%
      filter(CD_HAB == V_peu)
  }
  else {placette_ecoregion_F <<- placette_ecoregion_F}
    
  
  
  return(placette_ecoregion_F)
}



# Obtenir l'ensemble les données écologique des placettes dans la zone dessiné----
get_data_eco <- function(){
  get_import_zone()
  get_buffer_zone()
  get_read_map()
  get_pla_eco()
  get_proportion_eco()
  get_data_value()
  filtre_peuplement()
  View(placette_ecoregion_F)
  return(plot_zone)
}

get_data_eco()
