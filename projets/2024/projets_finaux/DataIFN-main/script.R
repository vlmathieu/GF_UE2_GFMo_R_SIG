# Descriptif du projet R ----
# Projet extraction données IFN
# Nom du projet : DataIFN
# Auteurs : PENET Mathieu / PERIER Benoit / DELAGES Jean-Eudes / GARDES Roman
# Etudiant AgroParisTech

# Instalations des packages ----

install.packages("remotes")  # Permets d'importer les données Github nécessaire
install.packages("devtools")
install.packages("data.table")
install.packages("sf")  # Package SIG
install.packages("ggplot2")
install.packages("dplyr")
install.packages("happifn")
install.packages("tidyr")
install.packages("tmap")
install.packages("kableExtra")
install.packages("mapview")
install.packages("mapedit")
install.packages("leaflet")

# Installation du dossier de travail ----
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
dir <- getwd()



# Installation des extensions Github ----
devtools::install_github("paul-carteron/happifn")

# Installation des librairies ----
library(happifn)
library(happifndata)
check_happifndata()
library(FrenchNFIfindeR)
library(data.table)
library(sf)
library(ggplot2)
library(dplyr)
library(tidyr)
library(tmap);ttm
library(kableExtra)
library(mapview)
library(mapedit)
library(leaflet)


# Chargement des fonction de récupération des données IFN ----
#get_ifn_all()
get_dataset_names()  # Permet d'obtenir les noms des fichiers fournis par IFN
arbre <- get_ifn("arbre")
placette <- get_ifn("placette")
habitat <- get_ifn("habitat")
#ecologie <- get_ifn("ecologie")
metadata <-get_ifn_metadata()  # Chargement des metadonnee

# On charge indépendament toutes les listes de metadata
code <- metadata[[1]]
units <- metadata[[2]]
units_value_set <- metadata[[3]]

# On identifie les codes essences
code_essence <- units_value_set %>% 
  filter(units == "ESPAR")
code_veget <- units_value_set %>% 
  filter(units == "VEGET5")

#code_ecologie <- units_value_set %>%
  filter(units %in% c("TOPO", "OBSTOPO", "HUMUS", "OLT", "TSOL", "TEXT1", "TEXT2", "ROCHED0"))


get_pplmt() 
  
  
# Activation des fonctions----

get_acc_G()

get_acc_V()

get_acc_D()

mel <- arbre_zone_etude_cor[arbre_zone_etude_cor$Essence=="Mélèze d'Europe",]

get_acc_G_reg_foret("PLAINE CORSE ORIENTALE")

get_acc_G_sylvo_eco("Ardenne primaire")

get_calc_taux_acc_G()

get_tarif_schaeffer()

get_accroissements_V()

