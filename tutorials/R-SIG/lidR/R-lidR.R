# About this code ----

# Description du script : Un script illustrant l'usage des fonctions
# du package "lidR" pour l'analyse de données Lidar pour les sciences
# forestière.

# Usage : "./tutorials/R-SIG/lidR/R-lidR.r"

# Last update: 02 Septembre 2024

# Auteur : Valentin Mathieu, sur la base du cours de Cédric Véga (IGN, LIF)

# Contact : valentin.mathieu@agroparistech.fr

# Institutions :
# 1 Université de Lorraine, AgroParisTech, INRAE, UMR SILVA, 54000 Nancy, France
# 2 Université de Lorraine, Université de Strasbourg, AgroParisTech,
# CNRS, INRAE, UMR BETA, 54000 Nancy, France

# Partie 1 : manipulation de données Lidar ----

# Charger les librairies
library(terra)  # Pour manipuler des données spatialisées
library(leaps)  # Sélection de sous-ensembles de régression
library(lidR)  # Pour manipuler les données Lidar
library(rstudioapi)  # Pour collecter les chemins vers les fichiers
library(sp)  # Classes et méthodes pour les données spatiales
library(raster)  # Ancienne version du package terra
library(sf)  # Pour manipuler des données vecteur
# help ("lidR")

# Set directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
dir <- getwd()

# Charger le nuage de point .laz en utilisant la fonction readLAS
# ?lidR::readLAS
file_path <- list.files(path = dir, pattern = ".laz", full.names = TRUE)
las <- readLAS(file_path)

# Explorer le fichier las
print(paste0("Nombre de ligne : ", nrow(las)))
print(paste0("Nombre de colonnes : ", ncol(las)))
print(paste0("Attributs : ", paste0(names(las), collapse = " ")))
print(paste0("Etendue spatiale : ",
             paste0(unlist(st_bbox(las)),
                    collaspe = " ")))

# Explorer le champ “classification”
table(las@data$Classification)
hist(las@data$Classification)
str(las)

# Découpage de données
# méthode clip_roi
clip_bb <- st_bbox(las) - 900
clip_las <- clip_roi(las, clip_bb)
plot(clip_las)

# méthode clip_rectangle
xmin <- st_bbox(las)[1]
xmax <- st_bbox(las)[1] + 100
ymin <- st_bbox(las)[2]
ymax <- st_bbox(las)[2] + 100
clip_las <- clip_rectangle(las, xmin, ymin, xmax, ymax)

# Afficher le nuage de points avec différentes options
str(las@data)
plot(clip_las, color = "Classification")
plot(clip_las, color = "NumberOfReturns")
plot(clip_las, color = "Intensity", breaks = "quantile", nbreaks = 50)


# Partie 2 : Génération de modèles numériques et normalisées ----

# Generation d'un modèle numérique de terrain
ting <- lidR::rasterize_terrain(clip_las, res = 0.5, algorithm = tin())
plot(ting)

# Generation d’un effet d’ombrage
tin_deriv <- terrain(ting, v = c("slope", "aspect"), unit = "radians")
tin_shade <- shade(slope = tin_deriv$slope, aspect = tin_deriv$aspect)
plot(tin_shade)
plot(tin_shade, col = gray(0:30 / 30), legend = FALSE)

# Comparaison d’algorithmes
knnidwg <- lidR::rasterize_terrain(clip_las, res = 0.5, algorithm = knnidw())
plot(knnidwg)

knnidw_deriv <- terrain(knnidwg, v = c("slope", "aspect"), unit = "radians")
knnidw_shade <- shade(slope = knnidw_deriv$slope, aspect = knnidw_deriv$aspect)
plot(knnidw_shade)
plot(knnidw_shade, col = gray(0:30 / 30), legend = FALSE)

plot(knnidwg - ting)

# Génération d’un modèle numérique de surface
?lidR::rasterize_canopy
dsm <- lidR::rasterize_canopy(clip_las, res = 0.5, algorithm=dsmtin())
col <- height.colors(25)
plot(dsm, col = col)

# Génération d’un modèle numérique de canopée
chm <- dsm - ting
col <- height.colors(25)
plot(chm, col = col)

# Normalisation de nuage de points
?lidR::normalize_height
clip_las_h <- lidR::normalize_height(clip_las, ting)

# Extraction de points d’intérêt du nuage
clip_first <-  filter_poi(clip_las_h, ReturnNumber == 1L)
plot(clip_first)


# Partie 3 : extraction de descripteur de la canopé ----

# Descripteurs surfaciques
cmetric <-  cloud_metrics(clip_las_h, func = .stdmetrics)
cmetric <-  data.frame(t(sapply(cmetric, c)))
cmetric

pmetric <-  pixel_metrics(clip_las_h, mean(Z), 5)
plot(pmetric)
summary(pmetric)

pmetric <- pixel_metrics(clip_las_h, mean(Z), 5, filter =  ~ReturnNumber == 1)
plot(pmetric)
summary(pmetric)

f <- function(i) {
  list(mean = mean(i))
}

pmetric <- pixel_metrics(clip_las_h, func =  ~f(Intensity))
plot(pmetric)

f2 <- function(z, i) {
  list(
    mean = mean(z),
    sd = sd(i)
  )
}

pmetric_sd <- pixel_metrics(clip_las_h, res = 0.5, func =  ~f2(Z, Z))
plot(pmetric_sd)


# Descripteurs objet
f <- function(x) {
  x * 0.1 + 3
}
heights <- seq(0, 30, 5)
ws <- f(heights)

?lidR::locate_trees
apex <- locate_trees(clip_las_h, lmf(f))
apex2 <- subset(apex, Z > 2)

plot(chm, col = height.colors(50))
plot(sf::st_geometry(apex), add = TRUE, pch = 3)

algo <- dalponte2016(chm, apex)
trees <- segment_trees(clip_las_h, algo)
plot(trees, bg = "white", size = 4, color = "treeID")


kernel <- matrix(1, 3, 3)
chm_smooth <- terra::focal(chm, w = kernel, fun = median, na.rm = TRUE)
apex <- locate_trees(chm_smooth, lmf(f))

plot(chm_smooth, col = height.colors(50))
plot(sf::st_geometry(apex), add = TRUE, pch = 3)

algo <- dalponte2016(chm_smooth, apex)
trees <- segment_trees(clip_las_h, algo)
plot(trees, bg = "white", size = 4, color = "treeID") 


algo <- li2012()
trees <- segment_trees(clip_las_h, algo)
plot(trees, bg = "white", size = 4, color = "treeID")


metrics <- crown_metrics(trees, ~list(z_max = max(Z), z_mean = mean(Z)))
head(metrics)


# Partie 4 : modélisation d’attributs forestiers ----

# Lecture du fichier
plots_path <- list.files(path = "./TD-3D", pattern = ".csv", full.names = TRUE)
plots <- read.csv(plots_path)
head(plots)
nrow(plots)

volume <- plots[, - c(3)]
models <- regsubsets(volume~., data = volume, nvmax = 5)
summary(models)

K <- 10
folds <- sample(1:K, nrow(volume), replace = TRUE)
err <- rep(NA, K)

for (i in 1:K){
  # on selectionne l'échantillon k
  fold_i <- which(folds == i)
  
  # on génère un jeu d'entrainement et de test
  volume_app <- volume[-fold_i, ]
  volume_test <- volume[fold_i, ]
  
  # on entraine le modèle linéaire
  app <- lm(volume~., data = volume_app)
  
  # on le teste sur le jeu d'évaluation
  pred <- predict(app, volume_test)
  
  # on calcule l'erreur de prédiction et on l'assigne au vecteur de sortie
  err[i] <- sqrt(mean((pred - volume_test$volume)^2))
}

# on calcule l'erreur moyenne et l'écart type de l'erreur sur les k folds
mean(err)
sd(err)

# on passe en pourcentage
mean(err) / mean(volume$volume) * 100
