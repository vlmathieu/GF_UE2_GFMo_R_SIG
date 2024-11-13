# A propos du code -----

# Titre du code : gpuachercher
# But du code : Recuperation des donnees relatives a la gestion forestiere sur 
# le geoportail de l'urbanisme
# Auteurs : Ninon Delattre, Adele Desaint, Sylvain Giraudo, Cyril Guillaumant, 
# Louise Rovel
# Contact : sylvain.giraudo13@gmail.com
# Derniere mise a jour : 12/09/2024

# Installation des packages ----

# Ce code necessite l'installation des packages rstudioapi et librarian

# Installation et chargement des packages
librarian::shelf(happign,dplyr,sf,tidyverse,tmap)
# Parametrage de tmap
tmap_mode("view"); tmap_options(check.and.fix = TRUE)

# Repertoire de travail -----

# Repertoire de travail relatif a la source du fichier 
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Nettoyage de l'environnement R ----
rm(list=ls())

# Importation des données ----

# Codes et libelles des prescriptions relatives a la gestion forestiere 
code_prescription_general <- c("01", "07", "18", "19", "25", "31", "34", "35",
                               "43", "46", "99")
libelle_prescription_general <- c(
  "Espace boisé classé",
  "Patrimoine bâti, paysager ou éléments de paysages à protéger",
  "Périmètre comportant des orientations d’aménagement et deprogrammation 
  (OAP)",
  "Secteur protégé en raison de la richesse du sol et du sous-sol",
  "Eléments de continuité écologique et trame verte et bleue",
  "Espaces remarquables du littoral",
  "Espaces, paysage et milieux caractéristiques du patrimoine naturel et 
  culturel montagnard à préserver",
  "Terres nécessaires au maintien et au développement des activités agricoles, 
  pastorales et forestières à préserver",
  "Réalisation d’espaces libres, plantations, aires de jeux et de loisir",
  "Constructibilité espace boisé antérieur au 20ème siècle",
  "Autre")

# Codes et libelles des prescriptions relatives aux enjeux patrimoniaux
code_prescription_patrimonial <- c("01", "07", "18", "31", "34", "35", "43",
                                   "46", "99")
libelle_prescription_patrimonial <- c(
  "Espace boisé classé",
  "Patrimoine bâti, paysager ou éléments de paysages à protéger",
  "Périmètre comportant des orientations d’aménagement et deprogrammation 
  (OAP)",
  "Espaces remarquables du littoral",
  "Espaces, paysage et milieux caractéristiques du patrimoine naturel et 
  culturel montagnard à préserver",
  "Terres nécessaires au maintien et au développement des activités agricoles, 
  pastorales et forestières à préserver",
  "Réalisation d’espaces libres, plantations, aires de jeux et de loisir",
  "Constructibilité espace boisé antérieur au 20ème siècle",
  "Autre")

# Codes et libelles des prescriptions relatives aux enjeux ecologiques
code_prescription_ecologique <- c("01","18", "25", "34", "43", "99")
libelle_prescription_ecologique <- c(
  "Espace boisé classé",
  "Périmètre comportant des orientations d’aménagement et deprogrammation 
  (OAP)",
  "Eléments de continuité écologique et trame verte et bleue",
  "Espaces, paysage et milieux caractéristiques du patrimoine naturel et 
  culturel montagnard à préserver",
  "Réalisation d’espaces libres, plantations, aires de jeux et de loisir",
  "Autre")

# Codes et libelles des informations relatives a la gestion forestiere 
code_info_general <- c("03", "08", "16", "21", "22","25", "37", "40", "99")
libelle_info_general <- c(
  "Zone de préemption dans un espace naturel et sensible",
  "Périmètre forestier : interdiction ou réglementation des plantations (code 
  rural et de la pêche maritime), plantations à réaliser et semis d'essence 
  forestière",
  "Site archéologique",
  "Projet de plan de prévention des risques",
  "Protection des rives des plans d'eau en zone de montagne",
  "Périmètre de protection des espaces agricoles et naturels périurbain",
  "Bois ou forêts relevant du régime forestier",
  "Périmètre d’un bien inscrit au patrimoine mondial ou Zone tampon d’un bien 
  inscrit au patrimoine mondial",
  "Autre")

# Codes et libelles des informations relatives aux enjeux patrimoniaux
code_info_patrimonial <- c("16", "25", "40", "99")
libelle_info_patrimonial <- c(
  "Site archéologique",
  "Périmètre de protection des espaces agricoles et naturels périurbain",
  "Périmètre d’un bien inscrit au patrimoine mondial ou Zone tampon d’un bien 
  inscrit au patrimoine mondial",
  "Autre")

# Codes et libelles des informations relatives aux enjeux ecologiques 
code_info_ecologique <- c("03", "22", "99")
libelle_info_ecologique <- c(
  "Zone de préemption dans un espace naturel et sensible",
  "Protection des rives des plans d'eau en zone de montagne",
  "Autre")
                  
# Codes et libelles des SUP relatives a la gestion forestiere 
code_sup_general <- c("a1","a7","a8","el9","a4","as1","ac3","el10","a10",
                "ac1","ac4","ac2","pm1","el2","pm2","pm4","pm5",
                "pm6","pm7","pm8","pm9")
libelle_sup_general <- c(
  "Serviture de protection des bois et forêts relevant du régime forestier à 
  Mayotte",
  "Servitude relative aux forêts dites de protection",
  "Servitures résultant de la mise en défens des terrains et pâturages en 
  montagnes et dunes du Pas-de-Calais",
  "Servitudes de passage sur le littoral",
  "Servitudes de passage dans le lit ou sur les berges d'un cours d'eau",
  "Servitudes résultant de l'instauration de périmètres de protection autour 
  des captaux d'eaux et des sources minérales naturelles",
  "Réserves naturelles et périmètres de protection autour des réserves 
  naturelles",
  "Coeur de parc national",
  "Zones de protection naturelle, agricole et forestière du plateau de Saclay",
  "Servitudes relatives aux monuments historiques",
  "Sites patrimoniaux remarquables, zones de protection et de valorisation du 
  patrimoine architectural, urbain et paysager",
  "Servitudes relatives aux sites inscrits et classés",
  "Plans de prévention des risques naturels prévisibles (PPRNP) et plans de 
  prévention de risques miniers (PPRM) et documents valant PPRNP",
  "Servitude qui concerne la Loire et ses affluents",
  "Servitudes d'inondation pour la rétention des crues du Rhin",
  "Servitudes autour des installations classées pour la protection de 
  l’environnement et sur des sites pollués, de stockage de déchets ou 
  d’anciennes carrières",
  "Servitude relative aux zones de rétention d’eau et aux zones dites 
  'stratégiques pour la gestion de l’eau'",
  "Servitudes visant à ne pas aggraver les risques pour la sécurité publique en 
  présence d’un ouvrages hydraulique",
  "Servitudes autour des installations nucléaires de base",
  "Servitudes relatives aux ouvrages ou infrastructures permettant de prévenir 
  les inondations ou les submersions",
  "Servitudes relatives à la création, la continuité,la pérennité et 
  l’entretien des équipements de défense des forêts contre les incendies 
  (DFCI)",
  "Servitudes relatives aux zones de danger")

# Codes et libelles des SUP relatives aux enjeux patrimoniaux 
code_sup_patrimonial <- c("a10","ac1","ac4","ac2")

libelle_sup_patrimonial <- c(
   "Zones de protection naturelle, agricole et forestière du plateau de Saclay",
   "Servitudes relatives aux monuments historiques",
   "Sites patrimoniaux remarquables, zones de protection et de valorisation du 
   patrimoine architectural, urbain et paysager",
   "Servitudes relatives aux sites inscrits et classés")

# Codes et libelles des SUP relatives aux enjeux ecologiques 
code_sup_ecologique <- c("a8","a4","as1","ac3","el10","a10")
libelle_sup_ecologique <- c(
   "Servitures résultant de la mise en défens des terrains et pâturages en 
   montagnes et dunes du Pas-de-Calais",
   "Servitudes de passage dans le lit ou sur les berges d'un cours d'eau",
   "Servitudes résultant de l'instauration de périmètres de protection autour 
   des captaux d'eaux et des sources minérales naturelles",
   "Réserves naturelles et périmètres de protection autour des réserves 
   naturelles",
   "Coeur de parc national",
   "Zones de protection naturelle, agricole et forestière du plateau de Saclay")

# Selection des colonnes utiles dans les tableaux des generateurs et assiettes 
# de SUP
col_utiles_gen <- c("gid","suptype","partition","fichier","nomgen","typegen",
                   "nomsuplitt","geometry")
col_utiles_ass <- c("gid","suptype","partition","fichier","nomass","typeass",
                   "nomsuplitt","geometry")

# Uniformisation des noms de colonnes des tableaux des generateurs et assiettes 
# de SUP
noms_def <- c("gid","suptype","partition","fichier","nom","libelle",
              "nomsuplitt","geometry")

# Rassemblement de toutes les listes dans un seul repertoire
dico <- list(code_prescription_general = code_prescription_general,
             libelle_prescription_general = libelle_prescription_general,
             code_prescription_patrimonial = code_prescription_patrimonial,
             libelle_prescription_patrimonial = 
               libelle_prescription_patrimonial,
             code_prescription_ecologique = code_prescription_ecologique,
             libelle_prescription_ecologique = libelle_prescription_ecologique,
             code_info_general = code_info_general,
             libelle_info_general = libelle_info_general,
             code_info_patrimonial = code_info_patrimonial,
             libelle_info_patrimonial = libelle_info_patrimonial,
             code_info_ecologique = code_info_ecologique,
             libelle_info_ecologique = libelle_info_ecologique,
             code_sup_general = code_sup_general,
             libelle_sup_general = libelle_sup_general,
             code_sup_patrimonial = code_sup_patrimonial,
             libelle_sup_patrimonial = libelle_sup_patrimonial,
             code_sup_ecologique = code_sup_ecologique,
             libelle_sup_ecologique = libelle_sup_ecologique,
             col_utiles_ass =  col_utiles_ass,
             col_utiles_gen = col_utiles_gen,
             noms_def = noms_def)

# Fonctions de recuperation des données ----

# Recuperation des prescriptions sur le GPU
get.gpu.prescription <- function(x, dico){
  
  # Recuperation des surfaces, lignes et points
  prescription_surf <- get_apicarto_gpu(x,
                                        ressource = c("prescription-surf"))
  prescription_lin <- get_apicarto_gpu(x,
                                       ressource = c("prescription-lin"))
  prescription_pct <- get_apicarto_gpu(x,
                                       ressource = c("prescription-pct"))
  prescription_pct <- prescription_pct[ ,
                                        !(names(prescription_pct) %in% "angle")]

  # Creation d'un seul tableau avec les donnees surfaciques, lineaires et 
  # ponctuelles
  prescription <- rbind(prescription_surf, prescription_lin, prescription_pct)

  # Tri des prescriptions grace aux listes definies en debut de code 
  if (!is.null(prescription)){
    prescription <- 
      filter(prescription, typepsc %in% dico[["code_prescription"]])
    
  }
  return(prescription)
}

get.gpu.info <- function(x, dico){

  # Recuperation des surfaces, lignes et points
  info_surf <- get_apicarto_gpu(x,
                                ressource = c("info-surf"))
  info_lin <- get_apicarto_gpu(x,
                               ressource = c("info-lin"))
  info_pct <- get_apicarto_gpu(x,
                               ressource = c("info-pct"))
  
  # Creation d'un seul tableau avec les donnees surfaciques, lineaires et 
  # ponctuelles
  info <- rbind(info_surf, info_lin, info_pct)
  
  # Tri des prescriptions grace aux liste definies en debut de code 
  if (!is.null(info)){
    info <- filter(info, typeinf %in% dico[["code_info"]])
    
  }
  return(info)
}

# Recuperation des informations relatives aux SUP
get.sup.gen <- function(x, dico){
  
  # Recuperation de tous les generateurs surfaciques, lineaires et ponctuelles 
  # de SUP utiles
  generateur_sup_s <- get_apicarto_gpu(x,
                                       ressource = "generateur-sup-s",
                                       dTolerance = 10,
                                       categorie = dico[["code_sup"]])
  
  
  generateur_sup_l <- get_apicarto_gpu(x,
                                       ressource = "generateur-sup-l",
                                       dTolerance = 10,
                                       categorie = dico[["code_sup"]])
  
  generateur_sup_p <- get_apicarto_gpu(x,
                                       ressource = "generateur-sup-p",
                                       dTolerance = 10,
                                       categorie = dico[["code_sup"]])  
  
  # Rassemblement des donnees surfaciques, lineaires et ponctuelles
  # Selection des colonnes utiles uniquement
  generateur <- rbind(
    generateur_sup_s[ ,dico[["col_utiles_gen"]]],
    generateur_sup_l[ ,dico[["col_utiles_gen"]]],
    generateur_sup_p[ ,dico[["col_utiles_gen"]]]
  )
  
  # Uniformisation des noms des colonnes 
  if(!is.null(generateur)){
    colnames(generateur) <- dico[["noms_def"]]
  }
  
  return(generateur)
  
}

get.sup.ass <- function(x, dico){
  
  # Recuperation de toutes les assiettes surfaciques, lineaires et ponctuelles 
  # de SUP utiles
  assiette_sup_s <- get_apicarto_gpu(x,
                                     ressource = "assiette-sup-s",
                                     dTolerance = 10,
                                     categorie = dico[["code_sup"]])
  
  
  assiette_sup_l <- get_apicarto_gpu(x,
                                     ressource = "assiette-sup-l",
                                     dTolerance = 10,
                                     categorie = dico[["code_sup"]])
  
  assiette_sup_p <- get_apicarto_gpu(x,
                                     ressource = "assiette-sup-p",
                                     dTolerance = 10,
                                     categorie = dico[["code_sup"]])
  
  # Rassemblement des donnees surfaciques, lineaires et ponctuelles
  # Selection des colonnes utiles uniquement
  assiette <- rbind(
    assiette_sup_s[ ,dico[["col_utiles_ass"]]],
    assiette_sup_l[ ,dico[["col_utiles_ass"]]],
    assiette_sup_p[ ,dico[["col_utiles_ass"]]]
  )
  
  # Uniformisation des noms des colonnes 
  if(!is.null(assiette)){
    colnames(assiette) <- dico[["noms_def"]]
  }
  
  return(assiette)
  
}

# Creation d'une liste des tableaux de donnees extraits du GPU
get.gpu.all <- function(x, dico){

  # Extraction des prescriptions, informations, generateurs et assiettes de SUP
  prescription <- get.gpu.prescription(x, dico)
  cat("\nprescription ok\n")
  info <- get.gpu.info(x, dico)
  cat("\ninfo ok\n")
  sup_gen <- get.sup.gen(x, dico)
  cat("\nSUP generateur ok\n")
  sup_ass <- get.sup.ass(x, dico)
  cat("\nSUP assiette ok\n")
  all_gpu <- list("prescriptions" = prescription,
                  "informations" = info,
                  "generateurs_sup" = sup_gen,
                  "assiettes_sup" = sup_ass)
  
  return(all_gpu)
}


# Fonctions de post-filtrage des donnees ----

# Fonction qui donne les differents libelles des documents d'urbanisme
libelle.urba <- function(df){
  
  if (!is.null(df)){
    info_df <- unique(df$libelle)
  }else {
    info_df <- c()
  }
  
  return(info_df)
}

# Fonction qui renvoie une liste des libelles voulus
select.libelle.urba <- function(df){
  
  # Recuperation et affichage des libelles 
  info_df <- libelle.urba(df) 
  cat("\nles libelles présents sont: \n\n")
  for (i in seq_along(info_df)) {
    cat(paste(i, info_df[i]), sep = "\n")
  }
  
  # Demande des libelles a l'utilisateur
  cat("\nVeuillez entrer une liste des numéros de ligne des libelles voulus
      séparés par des virgules \n(ex : 1,2,3) :")
  entree <- readline(prompt = "")
  
  #  Division des chaines en elements en utilisant la virgule comme separateur
  elements <- strsplit(entree, split = ",")[[1]] 
  numeros <- as.numeric(elements)
  liste_libelle <- info_df[numeros]

  # Affichage des choix de l'utilisateur
  cat("\nVous avez choisi les libelles suivant:\n")
  print(liste_libelle)
  
  return(liste_libelle)
}

# Fonction qui filtre un dataframe
filtre.libelle.urba <- function(df){
  
  liste_libelle <- select.libelle.urba(df)
  df_filter <- dplyr::filter(df,
                             libelle %in% liste_libelle)
  
  return(df_filter)
}

# Fonction pour filtrer tous les dataframe
post.filter <- function(all_gpu){

  all_gpu_filtered <- list()
  names_all_gpu <- names(all_gpu)
  
  # Filtre des dataframe contenus dans une liste un par un 
  for (i in seq_along(all_gpu)){
    
    df <- all_gpu[[i]]
    name_df <- names_all_gpu[i]
    if (is.null(df)){
      all_gpu_filtered <- c(all_gpu_filtered, 
                            list(df))
    } else {
      cat(paste("\n Dans", name_df))
      all_gpu_filtered <- c(all_gpu_filtered, 
                            list(filtre.libelle.urba(df)))
    }
  }
  
  return(all_gpu_filtered)
}



# Fonction d'affichage interactif ----

# Fonction pour afficher une carte interactive
affichage <- function(area, gpu_all, type = "Prescriptions"){
  
  # On peut afficher trois types de cartes 
  types <- c("Prescriptions", "Informations", "SUP")
  
  if (!type %in% types){
    stop ("Type must be 'Prescriptions', 'Informations' or 'SUP'")
  }
  
  # Utilisation de tmap en mode interactif
  tmap_mode("view")
  
  # Definition de l'affichage
  x <- 1  # Pour aller chercher le premier element de la liste gpu_all
  n <- 1  # Nombre iteration de la boucle for 
  if (type == "Informations"){
    x <- 2
  } else if (type == "SUP") {
    x <- 4
    n <- 2
  }
  
  # Creation de la carte interactive
  map <- tm_shape(area) +
    tm_borders(col = "black", lwd = 2) +
    tm_view(view.legend.position = c("right", "bottom"))
  
  
  for (i in 1:n){
    # Separation des types de geometries
    geometry_type <- st_geometry_type(gpu_all[[x]])
    
    polygones <- st_make_valid(gpu_all[[x]][geometry_type == "MULTIPOLYGON", ])
    lignes <- st_make_valid(gpu_all[[x]][geometry_type == "MULTILINESTRING", ])
    points <- st_make_valid(gpu_all[[x]][geometry_type == "MULTIPOINT", ])
    
    # Affichage des polygones
    if (nrow(polygones) > 0) {
      map <- map +
        tm_shape(polygones, group = "Polygones") +
        tm_fill(col = "libelle",
                alpha = ifelse(x == 4, 0.1, 0.9),
                palette = "Spectral",
                title = ifelse(x == 4, 
                               "Assiette SUP", 
                               paste(type, "surfaciques")), 
                legend.show = TRUE) +  
        tm_borders()
    }
    
    # Affichage des lignes
    if (nrow(lignes) > 0) {
      map <- map +
        tm_shape(lignes, group = "Lignes") +
        tm_lines(col = "libelle", 
                 palette = "Accent", 
                 title.col = ifelse(x == 4, 
                                    "Assiette SUP", 
                                    paste(type, "lineaires")),
                 legend.show = TRUE)
    }
    
    # Affichage des points
    if (nrow(points) > 0) {
      map <- map +
        tm_shape(points, group = "points") +
        tm_symbols(col = "libelle",
                   palette = "Paired",
                   shape = 21,
                   size = 0.2,
                   title.col = paste(type, "ponctuelles"))
    }
    x <- x - 1  # Pour passer de l'affichage des assiettes a l'affichage des 
                # generateurs
  }
  print(map)
  
}

# Affichage des trois types de cartes 
affichage.interactif <- function (area, gpu_all) {
  
  cat("\nLes trois cartes vont s'afficher au fur et à mesure.\n")
  
  for (type in c("Prescriptions", "Informations", "SUP")){
    
    cat(paste("\nAffichage des", type))
    
    affichage(area, gpu_all, type)
  }
}

# Fonction d'exportation sous forme de geopackage ----

# Exportation d'une liste de dataframe sous forme de geopackage 
export.list.to.gpkg <- function(gpu_all, gpkg_path) {
  
  layer_names <- c("prescriptions", 
                   "infos", 
                   "generateur", 
                   "assiette")
  
  # Chaque objet de la liste est nomme puis exporte sous forme de fichier dans 
  # un unique geopackage
  for (i in seq_along(gpu_all)) {
    df <- gpu_all[[i]]
    layer_name <- layer_names[i]
    st_write(df, gpkg_path, layer_name, append = T)
  }
}

# Fonction finale ----
final.function <- function(area,  # Geometrie
                           dico,  # Repertoire de listes
                           filter = "Patrimoine",  # Patrimoine,General ou 
                                                   # Ecologique
                           post_filter = FALSE,  # FALSE ou TRUE
                           working_dir = NULL,  # NULL ou repertoire de travail
                           buffer = 300,  # Entier en metres
                           display = FALSE,  # FALSE ou TRUE
                           export_gpkg = TRUE)  # TRUE ou FALSE
  {
  
  # area doit etre une geometrie de type sf ou sfc 
  if (!inherits(area, c("sf", "sfc"))) {
    stop("x must be of class sf or sfc.")
  }
  
  filter_ok <- c("Patrimoine", "General", "Ecologique")
  
  if (!filter %in% filter_ok){
    stop ("Type must be 'Patrimoine', 'General', 'Ecologique'")
  }
  
  # Transformation du systeme de projection de area vers Lambert 93
  area_2154 <- st_transform(area, 2154)
  
  # Ajout d'un buffer 
  area_2154_buffer <- st_buffer(area_2154, dist = buffer)
  
  # Recuperation des donnees dans les documents d'urbanisme
  # Definition du filtre
  if (filter == "General"){
    old_names <- c("code_prescription_general", 
                   "code_info_general", 
                   "code_sup_general")
  } else if(filter == "Patrimoine"){
    old_names <- c("code_prescription_patrimonial", 
                   "code_info_patrimonial", 
                   "code_sup_patrimonial")
  } else if (filter == "Ecologique"){
    old_names <- c("code_prescription_ecologique", 
                   "code_info_ecologique", 
                   "code_sup_ecologique")
  }
  new_names <- c("code_prescription", "code_info", "code_sup")
  names(dico)[names(dico) %in% old_names] <- new_names
  
  # Importation des donnees
  gpu_all <- get.gpu.all(area, dico)
  
  # Filtrage des donnees a posteriori
  if (post_filter == TRUE){
    gpu_all <- post.filter(gpu_all)
  }
  
  # Transformation du systeme de projection de gpu_all
  gpu_all_2154 <- list()
  
  for (df in gpu_all) {
    if (is.null(df)){
      gpu_all_2154 <- c(gpu_all_2154, 
                        df)
    } else{
      gpu_all_2154 <- c(gpu_all_2154, list(st_transform(df, 2154)))
    }
  }
  # Pre-affichage interactif
  if (display == TRUE){
    affichage.interactif(area, gpu_all_2154)
  }
  
  # Exportation sous format geopackage 'gpkg'
  if(export_gpkg == TRUE) {
    if(!is.null(working_dir)){
      setwd (working_dir) 
    }
    
    gpkg_path <- file.path(getwd(),"gpuachercher.gpkg")
    
    export.list.to.gpkg(gpu_all_2154, gpkg_path)
  }
  
  return(gpu_all_2154)
}

# TEST ----

area <- mapedit::drawFeatures()

gpu_all <- final.function(area, 
                          dico, 
                          filter = "Patrimoine", 
                          post_filter = F, 
                          display = T,
                          export_gpkg = F)
