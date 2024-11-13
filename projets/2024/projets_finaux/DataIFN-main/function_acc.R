# Fichier d'appelation des fonctions ----
# Ce fichier R répertorie l'ensemble des fonctions utilisables avec les données IFN

# Pour des questions d'optimistion
# CHARGER UNIQUMENT CE FICHIER AVEC LE BOUTON :
#----------SOURCE---------



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
  france_center <- c(2.2137, 46.2276)  # Longitude, Latitude approximative de la France
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


# Fonction obtention des peuplements sur les placettes----
get_pplmt <- function(buffer = 0){
  get_import_zone()
  get_buffer_zone(buffer)
  
  habitat_placette <<- habitat[habitat$IDP %in% idp_placette_tampon, ]
  
  # Effectuer une jointure gauche entre `arbre_zone_etude` et `habitat_placette` sur la colonne `IDP`
  arbre_zone_etude <<- arbre_zone_etude %>%
    group_by(IDP) %>%  # Groupement par essence pour faire la moyenne globale de toutes les placettes
    mutate(
      PPLT = habitat_placette$CD_HAB, na.rm = TRUE,
      .groups = 'drop'
    )
  
  get_read_map()
  
  return(habitat_placette)
  
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
  idp_placette_tampon <<- placette_tampon$IDP
  
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
  
  return(list(idp_placette_tampon,arbre_zone_etude))
}

# Fonction d'affichage des cartes avec placettes----
get_read_map <- function(){
  # Passer en mode interactif avec tmap
  tmap_mode("view")
  
  # Choisir le CRS de la zone d'étude
  common_crs <- st_crs(shp_etude)  
  zone_tampon <- st_transform(zone_tampon, common_crs)
  placette_tampon <- st_transform(placette_tampon, common_crs)
  
  
  # Calculer le nombre de placettes et d'arbres dans la zone tampon
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




# Fonction de calcul du taux d'accroissement pour le volume et la G
get_taux_acc_g <- function(){
  # Calculer le nombre d'arbres mesurés pour chaque essence et chaque placette (IDP)
  nombre_arbres_par_essence_placette <- arbre_zone_etude_cor %>%
    group_by(Essence, IDP) %>%
    summarise(
      nombre_arbres_mesures = sum(!is.na(acc_g_ha) & is.finite(acc_g_ha) & acc_g_ha != 0),  # Compte des arbres mesurés
      .groups = 'drop'
    )
  
  # Calculer les statistiques de capital et d'accroissement
  capital_placette <<- arbre_zone_etude_cor %>%

    group_by(Essence, IDP) %>%
    summarise(
      capital_essence = sum(g_max_ha, na.rm = TRUE),
      acc_essence = sum(
        if_else(!is.na(acc_g_ha), acc_g_ha, NA_real_), 
        na.rm = TRUE ), # Ignorer les NA générés lorsque les circonférences sont égales
      
      taux_acc_G = if_else(capital_essence != 0, acc_essence * 100 / capital_essence, NA_real_),# Éviter division par zéro
      .groups = 'drop'  # Retirer les groupes après le résumé
    ) %>%
    
    left_join(nombre_arbres_par_essence_placette, by = c("Essence", "IDP")) %>%
    
    # Nettoyer les valeurs infinies et quasi infinies
    mutate(
      capital_essence = if_else(is.finite(capital_essence), capital_essence, NA_real_),
      acc_essence = if_else(is.finite(acc_essence), acc_essence, NA_real_),
      taux_acc_G = if_else(is.finite(taux_acc_G), taux_acc_G, NA_real_)
    ) %>%
    
    # Filtrer les lignes avec des valeurs proches de zéro
    filter(
      #abs(capital_essence) > 1e-7,  # Retirer les lignes où capital_essence est presque zéro
      abs(acc_essence) > 1e-7,      # Retirer les lignes où acc_essence est presque zéro
      #abs(taux_acc_G) > 1e-7        # Retirer les lignes où taux_acc_G est presque zéro
    )
  
  View(capital_placette)
  
  return(capital_placette)
}
get_taux_acc_V <- function(){
  # Calculer le nombre d'arbres mesurés pour chaque essence et chaque placette (IDP)
  nombre_arbres_par_essence_placette <- arbre_zone_etude_cor %>%
    group_by(Essence, IDP) %>%
    summarise(
      nombre_arbres_mesures = sum(!is.na(acc_V_ha) & is.finite(acc_V_ha) & acc_V_ha != 0),  # Compte des arbres mesurés
      .groups = 'drop'
    )
  
  # Calculer les statistiques de capital et d'accroissement
  volume_placette <<- arbre_zone_etude_cor %>%
    
    group_by(Essence, IDP) %>%
    summarise(
      volume_essence = sum(V_max_ha, na.rm = TRUE),
      acc_essence = sum(
        if_else(!is.na(acc_V_ha), acc_V_ha, NA_real_), 
        na.rm = TRUE ), # Ignorer les NA générés lorsque les circonférences sont égales
      
      taux_acc_V = if_else(volume_essence != 0, acc_essence * 100 / volume_essence, NA_real_),# Éviter division par zéro
      .groups = 'drop'  # Retirer les groupes après le résumé
    ) %>%
    
    left_join(nombre_arbres_par_essence_placette, by = c("Essence", "IDP")) %>%
    
    # Nettoyer les valeurs infinies et quasi infinies
    mutate(
      volume_essence = if_else(is.finite(volume_essence), volume_essence, NA_real_),
      acc_essence = if_else(is.finite(acc_essence), acc_essence, NA_real_),
      taux_acc_V = if_else(is.finite(taux_acc_V), taux_acc_V, NA_real_)
    ) %>%
    
    # Filtrer les lignes avec des valeurs proches de zéro
    filter(
      #abs(capital_essence) > 1e-7,  # Retirer les lignes où capital_essence est presque zéro
      abs(acc_essence) > 1e-7,      # Retirer les lignes où acc_essence est presque zéro
      #abs(taux_acc_G) > 1e-7        # Retirer les lignes où taux_acc_G est presque zéro
    )
  
  View(volume_placette)
  
  return(volume_placette)
}

  



# Fonction d'arrangement des données par placette ----
get_arrange_data <- function(){
  
  # Fabrication d'un numéro unique pour chaque arbre
  # Nomencalture num unique "num placette.num arbre"
  arbre_zone_etude$num_unique <- paste(arbre_zone_etude$IDP,
                                       arbre_zone_etude$A,
                                       sep = ".")
  # Créer une nouvelle colonne qui stocke toutes les années de campagne pour chaque IDP
  arbre_zone_etude <- arbre_zone_etude %>%
    group_by(num_unique) %>%
    mutate(
      annee_mesure = paste(unique(CAMPAGNE), collapse = ", "),# Créer une chaîne de caractères avec les années uniques
      circ_mesure = paste(na.omit(C13), collapse = ", ")  # Créer une liste avec les mesures de circonférecnes
    ) %>%
    ungroup()
  
  # Les sections vides dans ESPAR sont remplacé par NA
  arbre_zone_etude$ESPAR[arbre_zone_etude$ESPAR == "" | arbre_zone_etude$ESPAR == " "] <- NA
  
  # Remplir les valeurs manquantes de code ESPAR pour chaque arbre
  arbre_zone_etude_cor <<- arbre_zone_etude %>%
    group_by(num_unique) %>%          # Grouper par le numéro unique
    fill(ESPAR, .direction = "downup") %>%  # Remplir les valeurs manquantes par les valeurs non manquantes
    ungroup()  # Désactiver le regroupement
  
  return (arbre_zone_etude_cor)
}

# Fonction de remplissage des libellés d'essence dans la table de données----
get_species <- function(){
  # Ajout de la colonne Essence
  arbre_zone_etude$Essence <- NA

  
  # Boucle de remplissage des libellés pour chaque code Essence
  for (i in 1:nrow(arbre_zone_etude_cor)) {
    # Récupérer le code ESPAR pour l'arbre à la ligne `i`
    code_espar <- arbre_zone_etude_cor$ESPAR[i]
    code_veget5 <- arbre_zone_etude_cor$VEGET[i]
    
    # Si le code ESPAR est NA, remplacer par le libelle de code_veget
    if (is.na(code_espar)) {
      # Ajouter l'essence correspondante depuis code_veget
      veget_correspondante <- code_veget$libelle[code_veget$code == code_veget5]
      arbre_zone_etude_cor$Essence[i] <- veget_correspondante
    } else {
      # Trouver l'essence correspondante dans la table `metadonnees`
      essence_correspondante <- code_essence$libelle[code_essence$code == code_espar]
      
      # Vérifier si une essence a été trouvée
      if (length(essence_correspondante) > 0) {
        # Ajouter l'essence à la colonne "Essence" de `arbre_zone_etude_cor`
        arbre_zone_etude_cor$Essence[i] <- essence_correspondante
      } else {
        # Si aucun code ESPAR correspondant n'est trouvé, laisser la valeur par défaut (NA)
        arbre_zone_etude_cor$Essence[i] <- "Indetermine"
      }
    }
  }
  arbre_zone_etude_cor <<- arbre_zone_etude_cor
  return(arbre_zone_etude_cor)
}  # A corriger la boucle for


# Fonction de récupération de l'état des arbres
get_veget <- function(){
  
  arbre_zone_etude_cor <<- arbre_zone_etude_cor %>%
    mutate(VEGET_cor = case_when(
      !is.na(VEGET5) ~ VEGET5,      # Si VEGET5 n'est pas NA, prendre VEGET5
      !is.na(VEGET) ~ VEGET,        # Si VEGET5 est NA mais VEGET n'est pas NA, prendre VEGET
      is.na(VEGET) & is.na(VEGET5) ~ "indetermine"  # Si les deux sont NA, inscrire "indetermine"
    ))
  # Ensuite, faisons une jointure avec la table code_veget pour obtenir les libellés
  arbre_zone_etude_cor <<- arbre_zone_etude_cor %>%
    left_join(code_veget, by = c("VEGET_cor" = "code")) %>%  # Assurez-vous que 'code' est la colonne correspondante dans code_veget
    mutate(veget_etat = libelle) %>%
    select(-definition, -libelle, -units)
  
  return(arbre_zone_etude_cor)
  
}



# Fonction option des principales variables dendrométrique des placettes----
get_data_dendro <- function(){
  
  # On sélectionne uniquement quelques colonnes utile
  arbre_zone_etude_cor <- arbre_zone_etude_cor %>%
    select(IDP,CAMPAGNE, num_unique, Essence, C13,C0, VEGET, VEGET5, HTOT, HDEC, V, W, IR5, IR1, annee_mesure, circ_mesure) %>%
    
    pivot_wider(names_from = CAMPAGNE,   # Créer des colonnes pour chaque année
                values_from = C13) %>%  # Les valeurs à placer dans ces colonnes sont les circonférences mesurées
    
    group_by(num_unique) %>%
    summarise(across(everything(), ~ first(na.omit(.)), .names = "{col}"), .groups = "drop")
  
  # On cherche la circonférence max dans la liste
  arbre_zone_etude_cor <<- arbre_zone_etude_cor %>%
    group_by(num_unique) %>%
    # Calculer l'accroissement annuel
    mutate(
      # Séparer la chaîne de caractères en vecteur d'années pour chaque ligne
      annee_vector = list(as.numeric(strsplit(annee_mesure, ",\\s*")[[1]])),
      circ_vector = list(as.numeric(strsplit(circ_mesure, ",\\s*")[[1]])),
      
      # Extraire l'année maximale et minimale
      annee_max = max(annee_vector[[1]], na.rm = TRUE),  # L'année de la circonférence max
      annee_min = min(annee_vector[[1]], na.rm = TRUE),  # L'année de la circonférence min
      
      # Extraire la circonférence maximale et minimale
      circonference_max = max(circ_vector[[1]], na.rm = TRUE),  # La circonférence max
      circonference_min = min(circ_vector[[1]], na.rm = TRUE))%>%  # La circonférence min
    
    mutate(cat_diam = case_when(
      circonference_max >= 0.235 & circonference_max < 0.705 ~ "PB",   # Petite Bois (PB)
      circonference_max >= 0.705 & circonference_max < 1.175 ~ "BM",  # Bois Moyen (BM)
      circonference_max >= 1.175 ~ "GB",  # Gros Bois (GB))
      TRUE ~ NA_character_ ))%>%
    
    mutate(W = as.numeric(W),  # Transformer la variable W en numeric
           w = case_when(
             !is.na(W) ~ W,  # Si W n'est pas NA, w prend la valeur de W
             is.na(W) & cat_diam == "PB" ~ 88.4,  # Si W est NA et cat_diam est "PB", w prend 88.4
             is.na(W) & cat_diam == "BM" ~ 39.3,  # Si W est NA et cat_diam est "BM", w prend 39.3
             is.na(W) & cat_diam == "GB" ~ 14.1,  # Si W est NA et cat_diam est "GB", w prend 14.1
             TRUE ~ NA_real_  # Si aucune condition n'est remplie, w prend NA
           )) %>%
    
    mutate(
      # On calcul le diamètre de l'arbre
      diam = round((circonference_max / pi)/0.01,1),
      # On calcul sa classe de diam
      clas_diam = round(diam / 5) * 5
    ) %>%
    
    mutate(
      # Calcul accroissement en G/ha/an
      g_min = ((circonference_min^2) / (4 * pi)),
      g_max = ((circonference_max^2) / (4 * pi)),
      g_max_ha = g_max * w
    )
  return(arbre_zone_etude_cor)
  
  
}



# Fonction calcul accroissement en G/ha/an ----
get_calc_G <- function(){
  arbre_zone_etude_cor <<- arbre_zone_etude_cor %>%
    group_by(num_unique) %>%
    # Calculer l'accroissement annuel en G
    mutate(
      acc_g_ha = if_else(
        circonference_max != circonference_min & veget_etat=="Arbre vivant sur pied",
        ((g_max - g_min) * w / (annee_max - annee_min)),
        NA_real_  # Sinon NA
      ))
  return(arbre_zone_etude_cor)
  
}

# Fonction calcul accroissement en V/m3/an----
get_calc_V_ha <- function() {
  arbre_zone_etude_cor <<- arbre_zone_etude_cor %>%
    group_by(num_unique) %>%
    # Calculer l'accroissement annuel en V
    mutate(
      # Calculer l'accroissement volumique par hectare
      acc_V_ha = if_else(!is.na(accroissement_volumique) & !is.na(w), 
                         accroissement_volumique * w, 
                         NA_real_)  # Si l'un des deux est NA, retourner NA
    )
  
  # Vérifier si acc_V_ha est bien calculé
  print(head(arbre_zone_etude_cor$acc_V_ha))  # Afficher les premières valeurs calculées
  
  return(arbre_zone_etude_cor)
}

# Fonction calcul accroissement en D/cm/an----
get_calc_D <- function(){
  arbre_zone_etude_cor <<- arbre_zone_etude_cor %>%
    group_by(num_unique) %>%
    # Calculer l'accroissement annuel en V
    mutate(
      HTOT = as.numeric(HTOT),
      acc_D_cm = if_else(
        circonference_max != circonference_min,
        
        (((circonference_max / pi) - (circonference_min / pi)) / (annee_max - annee_min)) * 100,
        
        NA_real_  # Sinon NA
      ))
}




# Fonction de lecture (affichage tableau) des valeurs d'accroissements ----
get_read_acc_G <- function(){
  
  # Calculer les moyennes d'accroissement par essence, catégorie de diamètre et placette
  table_recap_placette <- arbre_zone_etude_cor %>%
    filter(is.finite(acc_g_ha)) %>%  # Exclure les valeurs infinies et petites
    group_by(IDP, Essence, cat_diam) %>%  # Groupement par Placette, Essence et catégorie de diamètre
    summarise(
      moyenne_accroissement = sum(acc_g_ha, na.rm = TRUE),  # Moyenne d'accroissement pour chaque placette
      .groups = 'drop'
    )
  
  # Calculer la moyenne sur toutes les placettes par essence et catégorie de diamètre
  table_recap_global <- table_recap_placette %>%
    group_by(Essence, cat_diam) %>%  # Groupement par Essence et catégorie de diamètre seulement
    summarise(
      moyenne_accroissement_placettes = mean(moyenne_accroissement, na.rm = TRUE),  # Moyenne globale sur toutes les placettes
      .groups = 'drop'
    ) %>%
    mutate(moyenne_accroissement_placettes = round(moyenne_accroissement_placettes, 3)) %>%  # Arrondir à 0.001 près
    pivot_wider(
      names_from = cat_diam,  # Colonnes pour chaque catégorie de diamètre
      values_from = moyenne_accroissement_placettes,
      values_fill = list(moyenne_accroissement_placettes = NA)  # Remplir les valeurs manquantes avec NA
    ) %>%
    arrange(Essence)  # Trier par essence
  
  # Calculer la moyenne globale par essence sans distinction de catégorie de diamètre
  table_recap_global_sans_diam <<- arbre_zone_etude_cor %>%
    filter(is.finite(acc_g_ha)) %>%
    group_by(IDP, Essence) %>%  # Groupement par Placette et Essence uniquement
    summarise(
      moyenne_accroissement_sans_diam = sum(acc_g_ha, na.rm = TRUE),  # Moyenne d'accroissement par placette sans cat_diam
      nombre_arbres_mesures = sum(!is.na(acc_g_ha) & acc_g_ha != 0 & is.finite(acc_g_ha)),
      .groups = 'drop'
    ) %>%
    group_by(Essence) %>%  # Groupement par essence pour faire la moyenne globale de toutes les placettes
    summarise(
      moy_acc_g_m2_ha = mean(moyenne_accroissement_sans_diam, na.rm = TRUE),  # Moyenne globale sur toutes les placettes
      moy_taux_acc_G = mean(capital_placette$taux_acc_G[capital_placette$Essence == Essence], na.rm = TRUE),
      ecart_type = sd(capital_placette$taux_acc_G[capital_placette$Essence == Essence], na.rm = TRUE),
      total_arbres_mesures = sum(nombre_arbres_mesures, na.rm = TRUE),
      IC_inf = moy_taux_acc_G - 1.96 * (ecart_type / sqrt(total_arbres_mesures)),
      IC_sup = moy_taux_acc_G + 1.96 * (ecart_type / sqrt(total_arbres_mesures)),
      
      .groups = 'drop'
    ) %>%
    mutate(moy_acc_g_m2_ha = round(moy_acc_g_m2_ha, 3),
           moy_taux_acc_G = round(moy_taux_acc_G,1))  # Arrondir à 0.001 près
  
  # Fusionner les résultats avec ou sans catégorie de diamètre
  table_recap_final_G <<- table_recap_global %>%
    left_join(table_recap_global_sans_diam, by = "Essence")  # Ajouter la moyenne sans catégorie de diamètre
  
  View(table_recap_final_G)
  
  return()
  
}
get_read_acc_V <- function(){
  
  # Calculer les moyennes d'accroissement par essence, catégorie de diamètre et placette
  table_recap_placette <- arbre_zone_etude_cor %>%
    filter(is.finite(acc_V_ha)) %>%  # Exclure les valeurs infinies et petites
    group_by(IDP, Essence, cat_diam) %>%  # Groupement par Placette, Essence et catégorie de diamètre
    summarise(
      moyenne_accroissement = sum(acc_V_ha, na.rm = TRUE),  # Moyenne d'accroissement pour chaque placette
      .groups = 'drop'
    )
  
  # Calculer la moyenne sur toutes les placettes par essence et catégorie de diamètre
  table_recap_global <- table_recap_placette %>%
    group_by(Essence, cat_diam) %>%  # Groupement par Essence et catégorie de diamètre seulement
    summarise(
      moyenne_accroissement_placettes = mean(moyenne_accroissement, na.rm = TRUE),  # Moyenne globale sur toutes les placettes
      .groups = 'drop'
    ) %>%
    mutate(moyenne_accroissement_placettes = round(moyenne_accroissement_placettes, 3)) %>%  # Arrondir à 0.001 près
    pivot_wider(
      names_from = cat_diam,  # Colonnes pour chaque catégorie de diamètre
      values_from = moyenne_accroissement_placettes,
      values_fill = list(moyenne_accroissement_placettes = NA)  # Remplir les valeurs manquantes avec NA
    ) %>%
    arrange(Essence)  # Trier par essence
  
  # Calculer la moyenne globale par essence sans distinction de catégorie de diamètre
  table_recap_global_sans_diam <- arbre_zone_etude_cor %>%
    filter(is.finite(acc_V_ha)) %>%
    group_by(IDP, Essence) %>%  # Groupement par Placette et Essence uniquement
    summarise(
      moyenne_accroissement_sans_diam = sum(acc_V_ha, na.rm = TRUE),  # Moyenne d'accroissement par placette sans cat_diam
      nombre_arbres_mesures = sum(!is.na(acc_V_ha) & acc_V_ha != 0 & is.finite(acc_V_ha)),
      
      .groups = 'drop'
    ) %>%
    group_by(Essence) %>%  # Groupement par essence pour faire la moyenne globale de toutes les placettes
    summarise(
      moy_acc_V_m3_ha = mean(moyenne_accroissement_sans_diam, na.rm = TRUE),  # Moyenne globale sur toutes les placettes
      moy_taux_acc_V = mean(volume_placette$taux_acc_V[volume_placette$Essence == Essence], na.rm = TRUE),
      ecart_type = sd(volume_placette$taux_acc_V[volume_placette$Essence == Essence], na.rm = TRUE),
      total_arbres_mesures = sum(nombre_arbres_mesures, na.rm = TRUE),
      IC_inf = moy_taux_acc_V - 1.96 * (ecart_type / sqrt(total_arbres_mesures)),
      IC_sup = moy_taux_acc_V + 1.96 * (ecart_type / sqrt(total_arbres_mesures)),
      .groups = 'drop'
    ) %>%
    mutate(
      moy_acc_V_m3_ha = round(moy_acc_V_m3_ha, 3),
      moy_taux_acc_V = round( moy_taux_acc_V, 1))  # Arrondir à 0.001 près
  
  # Fusionner les résultats avec ou sans catégorie de diamètre
  table_recap_final_V <<- table_recap_global %>%
    left_join(table_recap_global_sans_diam, by = "Essence")  # Ajouter la moyenne sans catégorie de diamètre
  
  View(table_recap_final_V)
  
  return(table_recap_final_V)
  
}
get_read_acc_D <- function(){
  
  # Calculer les moyennes d'accroissement par essence, catégorie de diamètre et placette
  table_recap_placette <- arbre_zone_etude_cor %>%
    filter(is.finite(acc_D_cm)) %>%  # Exclure les valeurs infinies et petites
    group_by(IDP, Essence, cat_diam) %>%  # Groupement par Placette, Essence et catégorie de diamètre
    summarise(
      moyenne_accroissement = mean(acc_D_cm, na.rm = TRUE),  # Moyenne d'accroissement pour chaque placette
      .groups = 'drop'
    )
  
  # Calculer la moyenne sur toutes les placettes par essence et catégorie de diamètre
  table_recap_global <- table_recap_placette %>%
    group_by(Essence, cat_diam) %>%  # Groupement par Essence et catégorie de diamètre seulement
    summarise(
      moyenne_accroissement_placettes = mean(moyenne_accroissement, na.rm = TRUE),  # Moyenne globale sur toutes les placettes
      .groups = 'drop'
    ) %>%
    mutate(moyenne_accroissement_placettes = round(moyenne_accroissement_placettes, 3)) %>%  # Arrondir à 0.001 près
    pivot_wider(
      names_from = cat_diam,  # Colonnes pour chaque catégorie de diamètre
      values_from = moyenne_accroissement_placettes,
      values_fill = list(moyenne_accroissement_placettes = NA)  # Remplir les valeurs manquantes avec NA
    ) %>%
    arrange(Essence)  # Trier par essence
  
  # Calculer la moyenne globale par essence sans distinction de catégorie de diamètre
  table_recap_global_sans_diam <- arbre_zone_etude_cor %>%
    filter(is.finite(acc_D_cm)) %>%
    group_by(IDP, Essence) %>%  # Groupement par Placette et Essence uniquement
    summarise(
      moyenne_accroissement_sans_diam = mean(acc_D_cm, na.rm = TRUE),  # Moyenne d'accroissement par placette sans cat_diam
      .groups = 'drop'
    ) %>%
    group_by(Essence) %>%  # Groupement par essence pour faire la moyenne globale de toutes les placettes
    summarise(
      moy_acc_D_cm_an = mean(moyenne_accroissement_sans_diam, na.rm = TRUE),  # Moyenne globale sur toutes les placettes
      #nombre_arbres_mesures = sum(!is.na(acc_g_ha) & acc_g_ha != 0 & is.finite(acc_g_ha)),
      .groups = 'drop'
    ) %>%
    mutate(moy_acc_D_cm_an = round(moy_acc_D_cm_an, 3))  # Arrondir à 0.001 près
  
  # Fusionner les résultats avec ou sans catégorie de diamètre
  table_recap_final_D <<- table_recap_global %>%
    left_join(table_recap_global_sans_diam, by = "Essence")  # Ajouter la moyenne sans catégorie de diamètre
  
  View(table_recap_final_D)
  
  return(table_recap_final_D)
  
}




# Fonction de récupération des statistiques des valeurs calculé----
get_stat_essence <- function(){
  
  merged_data <- capital_placette %>%
    left_join(table_recap_final_G %>% select(Essence, moy_taux_acc_G), by = "Essence")
  
  # Calculer l'écart-type du taux d'accroissement pour chaque essence
  
  nombre_placettes_par_essence <- capital_placette %>%
    group_by(Essence) %>%
    summarise(
      nombre_placettes = n_distinct(IDP),  # Nombre unique de placettes (IDP) pour chaque essence
      .groups = 'drop'
    )
  statistique_essence <<- merged_data %>%
    group_by(Essence) %>%
    summarise(
      ecart_type_taux_acc_G = sqrt(mean((taux_acc_G - moy_taux_acc_G)^2, na.rm = TRUE)),
      nombre_placettes = n_distinct(IDP),  # Nombre unique de placettes (IDP) pour chaque essence
      .groups = 'drop'
    )
  
  
  # Afficher les résultats
  View(statistique_essence)
  
  
  
  
  
  return(statistiques_essence)
  
}


# Fonction intégral calcul de l'accroissement en G/ha/an sur les placettes
get_acc_G <- function(buffer = 0){
  get_import_zone()
  get_buffer_zone(buffer)
  get_read_map()
  get_arrange_data()
  get_species()
  get_data_dendro()
  get_veget()
  get_calc_G()
  get_taux_acc_g()
  get_read_acc_G()
  get_stat_essence()
  View(plot)
    
  return(plot_zone)
}

# Fonction intégral calcul de l'accroissement en D/cm/an
get_acc_D <- function(buffer = 0){
  get_import_zone()
  get_buffer_zone(buffer)
  get_read_map()
  get_arrange_data()
  get_species()
  get_data_dendro()
  get_veget()
  get_calc_D()
  get_read_acc_D()
  View(table_recap_final_D)
  
  return(plot_zone)
}



# Obtenir les placettes et arbre mesurer d'une sylvoecoregion ----
get_sylvo_eco <- function(sylvoecoregion) {
  # Charger les données ser
  data("ser")           # Charger l'objet 'ser'
  
  # Filtrer le polygone correspondant au nom donné
  shp_etude <<- ser %>% filter(ser$NomSER == sylvoecoregion)
  
  get_buffer_zone()
  get_read_map()
  
  return(plot_zone)
}

# Obtenir les placettes et arbre mesurer d'une région forestière ----
get_reg_foret <- function(reg_foret) {
  # Charger les données ser et des placettes
  data("rfn")           # Charger l'objet 'rfn'
  
  # Filtrer le polygone correspondant au nom donné
  shp_etude <<- rfn %>% filter(rfn$REGIONN == reg_foret)
  get_buffer_zone()
  get_read_map()
  
  return(plot_zone)
}

# Obtenir l'accroissement en G/m²/ha/an d'une sylvoecoregion----
get_acc_G_sylvo_eco <- function(sylvoecoregion){
  get_sylvo_eco(sylvoecoregion)
  get_arrange_data()
  get_species()
  get_data_dendro()
  get_veget()
  get_calc_G()
  get_taux_acc_g()
  get_read_acc_G()
  
  return(plot_zone)
  
}

# Obtenir l'accroissement en G/m²/ha/an d'une Région forestière----
get_acc_G_reg_foret <- function(reg_foret){
  get_reg_foret(reg_foret)
  get_arrange_data()
  get_species()
  get_data_dendro()
  get_veget()
  get_calc_G()
  get_taux_acc_g()
  get_read_acc_G()
  
  return(plot_zone)
  
}

# Obtenir l'accroissement en V/m3/ha/an d'une sylvoecoregion----
get_acc_V_sylvo_eco <- function(sylvoecoregion){
  get_sylvo_eco(sylvoecoregion)
  get_arrange_data()
  get_species()
  get_data_dendro()
  get_veget()
  
  arbre_zone_etude_cor <<- selectionner_essence(arbre_zone_etude_cor)
  arbre_zone_etude_cor <<- nettoyer_donnees(arbre_zone_etude_cor)
  modele_poly <<- ajuster_modele_polynomial(arbre_zone_etude_cor)
  
  # Lire les tarifs
  tarif_lent <<- lire_tarifs("./tarif_shaeffer_lent.csv")
  tarif_rapide <<- lire_tarifs("./tarif_shaeffer_rapide.csv")
  
  # Comparer et sélectionner le meilleur tarif
  best_tarif <<- comparer_tarifs(arbre_zone_etude_cor, tarif_lent, tarif_rapide)
  
  # Étape 2 : Calculer les accroissements volumétriques
  arbre_zone_etude_cor <<- calculer_accroissements_volumetriques(arbre_zone_etude_cor, best_tarif, tarif_lent, tarif_rapide)
  
  get_calc_V_ha()
  get_taux_acc_V()
  get_read_acc_V()
  
  # Afficher le résultat
  View(arbre_zone_etude_cor)
  
  return(plot_zone)
  
}

# Obtenir l'accroissement en V/m3/ha/an d'une région forestière----
get_acc_V_reg_foret <- function(reg_foret){
  get_reg_foret(reg_foret)
  get_arrange_data()
  get_species()
  get_data_dendro()
  get_veget()
  
  arbre_zone_etude_cor <<- selectionner_essence(arbre_zone_etude_cor)
  arbre_zone_etude_cor <<- nettoyer_donnees(arbre_zone_etude_cor)
  modele_poly <<- ajuster_modele_polynomial(arbre_zone_etude_cor)
  
  # Lire les tarifs
  tarif_lent <<- lire_tarifs("./tarif_shaeffer_lent.csv")
  tarif_rapide <<- lire_tarifs("./tarif_shaeffer_rapide.csv")
  
  # Comparer et sélectionner le meilleur tarif
  best_tarif <<- comparer_tarifs(arbre_zone_etude_cor, tarif_lent, tarif_rapide)
  
  # Étape 2 : Calculer les accroissements volumétriques
  arbre_zone_etude_cor <<- calculer_accroissements_volumetriques(arbre_zone_etude_cor, best_tarif, tarif_lent, tarif_rapide)
  
  get_calc_V_ha()
  get_taux_acc_V()
  get_read_acc_V()
  
  # Afficher le résultat
  View(arbre_zone_etude_cor)
  
  return(plot_zone)
  
}



# Fonction de jean eudes delages----

# Fonction pour afficher les essences disponibles et sélectionner une essence
selectionner_essence <- function(data) {
  essences_disponibles <- unique(data$Essence)
  print("Essences disponibles :")
  print(essences_disponibles)
  
  essence_selectionnee <- readline(prompt = "Veuillez sélectionner une essence : ")
  
  # Filtrer les données pour l'essence sélectionnée
  data <- subset(data, Essence == essence_selectionnee)
  
  if (nrow(data) == 0) {
    stop("Aucune donnée disponible pour l'essence sélectionnée.")
  }
  
  return(data)
}

# Fonction pour nettoyer les données (enlever NA, convertir en numérique)
nettoyer_donnees <- function(data) {
  data <- data[!is.na(data$diam) & !is.na(data$V), ]
  
  # Convertir les colonnes en numériques
  data$diam <- as.numeric(data$diam)
  data$V <- as.numeric(data$V)
  
  return(data)
}

# Fonction pour ajuster le modèle polynomial
ajuster_modele_polynomial <- function(data) {
  modele_poly <- lm(V ~ poly(diam, 2), data = data)
  return(modele_poly)
}

# Fonction pour lire les fichiers de tarifs
lire_tarifs <- function(filepath) {
  tarif <- read.csv(filepath, header = TRUE, sep = ';')
  tarif[] <- lapply(tarif, function(x) gsub(",", ".", x))  # Remplacer les virgules par des points
  tarif$Diametre <- as.numeric(tarif$Diametre)  # Convertir les colonnes en numériques
  tarif[, 2:ncol(tarif)] <- lapply(tarif[, 2:ncol(tarif)], as.numeric)
  return(tarif)
}

# Fonction pour calculer l'erreur quadratique moyenne (MSE)
calculate_mse <- function(vol_predicted, vol_actual) {
  if (any(is.na(vol_predicted)) || any(is.na(vol_actual))) {
    return(NA)  # Retourner NA si des valeurs manquent
  }
  return(mean((vol_predicted - vol_actual)^2))
}

# Fonction pour comparer le modèle polynomial avec un tarif donné
compare_with_tarif <- function(tarif_data, tarif_type, data) {
  diameters <- tarif_data$Diametre
  mse_values <- c()
  
  for (i in 2:ncol(tarif_data)) {  # Les colonnes 2 à n sont les volumes
    volumes_tarif <- tarif_data[[i]]
    
    # Interpolation pour correspondre aux diamètres de l'étude
    volumes_interp <- approx(diameters, volumes_tarif, data$diam, rule = 2)$y
    
    # Vérifier si les volumes interpolés contiennent des NA
    if (all(is.na(volumes_interp))) {
      next  # Si tous les volumes interpolés sont NA, ignorer cette courbe
    }
    
    # Calcul de la MSE entre le modèle polynomial et le tarif
    mse <- calculate_mse(data$V, volumes_interp)
    mse_values <- c(mse_values, mse)
  }
  
  # Retourner la MSE la plus faible, l'index du tarif correspondant, et le type de tarif
  if (length(mse_values) == 0 || all(is.na(mse_values))) {
    return(list(min_mse = Inf, best_tarif = NA, type = tarif_type))
  }
  
  min_mse <- min(mse_values, na.rm = TRUE)
  best_tarif <- which.min(mse_values) + 1  # +1 à cause de la colonne 'Diametre'
  return(list(min_mse = min_mse, best_tarif = best_tarif, type = tarif_type))
}

# Fonction pour comparer les tarifs lents et rapides
comparer_tarifs <- function(data, tarif_lent, tarif_rapide) {
  best_tarif_lent <- compare_with_tarif(tarif_lent, "lent", data)
  best_tarif_rapide <- compare_with_tarif(tarif_rapide, "rapide", data)
  
  # Comparer les MSE pour déterminer le meilleur tarif
  best_tarif <- best_tarif_lent
  if (!is.na(best_tarif_rapide$min_mse) && best_tarif_rapide$min_mse < best_tarif$min_mse) {
    best_tarif <- best_tarif_rapide
  }
  
  return(best_tarif)
}

# Fonction pour visualiser les résultats
visualiser_resultats <- function(data, modele_poly, best_tarif, tarif_lent, tarif_rapide) {
  # Plot des données
  plot(data$diam, data$V, 
       xlab = "Diamètre (cm)", 
       ylab = "Volume (m³)", 
       main = "Volume en fonction du diamètre", 
       pch = 16, col = "blue")
  
  # Ajout de la courbe polynomiale
  lines(sort(data$diam), 
        predict(modele_poly, newdata = data.frame(diam = sort(data$diam))), 
        col = "green", lwd = 2)
  
  # Ajouter la courbe du tarif Shaeffer choisi
  tarif_data <- if (best_tarif$type == "lent") tarif_lent else tarif_rapide
  volumes_tarif <- tarif_data[[best_tarif$best_tarif]]
  volumes_interp <- approx(tarif_data$Diametre, volumes_tarif, data$diam, rule = 2)$y
  
  lines(sort(data$diam), 
        volumes_interp[order(data$diam)], 
        col = "red", lwd = 2, lty = 2)
  
  print(paste("Le meilleur tarif est :", best_tarif$best_tarif, 
              "de type", best_tarif$type, 
              "avec une MSE de", best_tarif$min_mse))
}

# Fonction principale pour exécuter le process de détermination de tarif Schaeffer
get_tarif_schaeffer <- function(buffer = 0) {
  get_import_zone()
  get_buffer_zone(buffer)
  get_read_map()
  get_arrange_data()
  get_species()
  get_data_dendro()
  
  # Sélectionner l'essence
  arbre_zone_etude_cor <- selectionner_essence(arbre_zone_etude_cor)
  
  # Nettoyer les données
  arbre_zone_etude_cor <- nettoyer_donnees(arbre_zone_etude_cor)
  
  # Ajuster le modèle polynomial
  modele_poly <- ajuster_modele_polynomial(arbre_zone_etude_cor)
  
  # Lire les tarifs
  tarif_lent <- lire_tarifs("./tarif_shaeffer_lent.csv")
  tarif_rapide <- lire_tarifs("./tarif_shaeffer_rapide.csv")
  
  # Comparer les tarifs et obtenir le meilleur
  best_tarif <- comparer_tarifs(arbre_zone_etude_cor, tarif_lent, tarif_rapide)
  
  # Visualiser les résultats
  visualiser_resultats(arbre_zone_etude_cor, modele_poly, best_tarif, tarif_lent, tarif_rapide)
}


# Nouvelle fonction : Calcul des accroissements volumétriques
calculer_accroissements_volumetriques <- function(arbre_zone_etude_cor, best_tarif, tarif_lent, tarif_rapide) {
  # Extraire les valeurs de M pour un diamètre de 45
  M_lent_45 <- tarif_lent[tarif_lent$Diametre == 45, ]
  M_rapide_45 <- tarif_rapide[tarif_rapide$Diametre == 45, ]
  
  # Calculer le diamètre maximum et minimum
  arbre_zone_etude_cor$diam_max <- arbre_zone_etude_cor$circonference_max / pi
  arbre_zone_etude_cor$diam_min <- arbre_zone_etude_cor$circonference_min / pi
  arbre_zone_etude_cor$accroissement_volumique <- NA
  arbre_zone_etude_cor$V_max <- NA  # Initialise la colonne V_max avec des NA
  arbre_zone_etude_cor$V_max_ha <- NA  # Initialise la colonne V_max avec des NA
  
  # Boucle sur chaque arbre pour calculer l'accroissement volumétrique
  for (i in 1:nrow(arbre_zone_etude_cor)) {
    ligne <- arbre_zone_etude_cor[i, ]
    
    if (!is.na(ligne$veget_etat) && ligne$veget_etat != "Arbre vivant sur pied") {
      arbre_zone_etude_cor$accroissement_volumique[i] <- NA
      next
    }
    
    
    if (ligne$diam_max != ligne$diam_min) {
      difference_annees <- ligne$annee_max - ligne$annee_min
      
      if (best_tarif$type == "lent") {
        # Calcul avec tarif lent
        
        M <- M_lent_45[[best_tarif$best_tarif]]
        V_lent_max <- (M / 1400) * ((ligne$diam_max * 100 - 5) * (ligne$diam_max * 100 - 10))
        V_lent_min <- (M / 1400) * ((ligne$diam_min * 100 - 5) * (ligne$diam_min * 100 - 10))
        accroissement_total <- V_lent_max - V_lent_min
        
        arbre_zone_etude_cor$V_max[i] <- V_lent_max  # Remplace NA par la valeur calculée pour chaque ligne
        # Calculer V_max_ha (V_max * w) et ajouter la valeur dans la colonne V_max_ha
        arbre_zone_etude_cor$V_max_ha[i] <- V_lent_max * ligne$w  # Multiplie V_max par w pour chaque ligne
        
      } else {
        # Calcul avec tarif rapide
        M <- M_rapide_45[[best_tarif$best_tarif]]
        V_rapide_max <- (M / 1800) * ligne$diam_max * 100 * (ligne$diam_max * 100 - 5)
        V_rapide_min <- (M / 1800) * ligne$diam_min * 100 * (ligne$diam_min * 100 - 5)
        accroissement_total <- V_rapide_max - V_rapide_min
        
        arbre_zone_etude_cor$V_max[i] <- V_rapide_max  # Remplace NA par la valeur calculée pour chaque ligne
        arbre_zone_etude_cor$V_max_ha[i] <- V_rapide_max * ligne$w  # Multiplie V_max par w pour chaque ligne
        
        
      }
      
      # Calcul de l'accroissement volumique annuel
      arbre_zone_etude_cor$accroissement_volumique[i] <- accroissement_total / difference_annees
    } else {
      # Pas d'accroissement si annee_max == annee_min
      arbre_zone_etude_cor$accroissement_volumique[i] <- NA
    }
  }
  
  # Retourner les données mises à jour
  return(arbre_zone_etude_cor)
}


# Fonction principale : get_accroissements_V
get_accroissements_V <- function(buffer = 0) {
  # Étape 1 : Préparer les données
  get_import_zone()
  get_buffer_zone(buffer)
  get_read_map()
  get_arrange_data()
  get_species()
  get_data_dendro()
  get_veget()
  
  arbre_zone_etude_cor <<- selectionner_essence(arbre_zone_etude_cor)
  arbre_zone_etude_cor <<- nettoyer_donnees(arbre_zone_etude_cor)
  modele_poly <<- ajuster_modele_polynomial(arbre_zone_etude_cor)
  
  # Lire les tarifs
  tarif_lent <<- lire_tarifs("./tarif_shaeffer_lent.csv")
  tarif_rapide <<- lire_tarifs("./tarif_shaeffer_rapide.csv")
  
  # Comparer et sélectionner le meilleur tarif
  best_tarif <<- comparer_tarifs(arbre_zone_etude_cor, tarif_lent, tarif_rapide)
  
  # Étape 2 : Calculer les accroissements volumétriques
  arbre_zone_etude_cor <<- calculer_accroissements_volumetriques(arbre_zone_etude_cor, best_tarif, tarif_lent, tarif_rapide)
  
  get_calc_V_ha()
  get_taux_acc_V()
  get_read_acc_V()
  
  # Afficher le résultat
  View(arbre_zone_etude_cor)
  return(arbre_zone_etude_cor)
}
