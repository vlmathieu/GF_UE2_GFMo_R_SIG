# Rappel sur R et SIG - R Basics
# Apprendre les bases sur l'importation et l'exploration de données
# Auteur : Valentin Mathieu (UMR Silva, AgroParisTech)
# Contact : valentin.mathieu@agroparistech.fr
# Dernière mise à jour : septembre 2024

# Alternative : 

# About this code ----

# Description du script : Un script "jouet" pour expliciter
# les fonctions de base de R pour le cours "Rappel sur R et le SIG
# pour la gestion forestière"

# Usage : ./tutorials/R-toy-script.r

# Last update: 02 Septembre 2024

# Auteur : Valentin Mathieu

# Institutions :
# 1 Université de Lorraine, AgroParisTech, INRAE, UMR SILVA, 54000 Nancy, France
# 2 Université de Lorraine, Université de Strasbourg, AgroParisTech,
# CNRS, INRAE, UMR BETA, 54000 Nancy, France

# Package installation ----
install.packages("dplyr")
install.packages("FAOSTAT")

# Libraries ----
library(tidyr)  # Formatting data for analysis
library(dplyr)  # Manipulating data
library(ggplot2)  # Visualising results
library(FAOSTAT)  # Downloading FAOSTAT data
# Notez que les packages sont indiqués entre guillemets pour l'installation
# mais sans guillemets pour le chargement du package.
# Laissez des commentaires pour expliciter pourquoi vous chargez tel ou tel
# package (et pour globalement tout ce que vous faites)

# Set working directory ----
setwd("/Users/valentinmathieu/Desktop/wd/GF_UE2_GFMo_R_SIG")
# C'est un exemple depuis mon ordinateur perso (un mac), à adapter à votre cas !

# Import data ----
FAO <- read.csv("./tutorials/FAOSTAT_data.csv",
                header=TRUE,
                sep = '\t')

# Exploring data ----
head(FAO)  # Displays the first few rows
tail(FAO)  # Displays the last rows
str(FAO)  # Tells you whether the variables are continuous, integers, categorical or characters

head(FAO$Item)  # Displays the first few rows of this column only
class(FAO$taxonGroup)  # Tells you what type of variable we're dealing with: it's character now but we want it to be a factor

FAO$taxonGroup <- as.factor(FAO$taxonGroup)  # What are we doing here?!
