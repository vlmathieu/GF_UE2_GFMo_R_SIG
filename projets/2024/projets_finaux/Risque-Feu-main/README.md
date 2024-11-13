### Titre: "UE2 - Projet risques feux de forêt"
*Auteurs: "DEBAS Adrien, FERGANI Nadjim, GIOVINAZZO Esteban, GOUFFON Valentin, VETTER Johann"*
##### Date: "2024-09-12"

 *** 
 
### Résumé:
Sujet de réflexion sur l'analyse des données DRIAS et du risque incendie. Nous avons ici réalisé une fonction principale ayant pour but de cartographier les zones à risque d'incendie selon différents facteurs. Pour cela, nous avons créé plusieurs sous-fonctions prenant en compte les données DRIAS, ainsi que la desserte forestière, les axes routiers principaux, les bâtiments à risque, l'inflammabilité et la combustibilité des peuplements forestiers.

*** 

### Les différents packages et modèles à installer 
 ```{r load_packages, include=FALSE}
library(happign)
library(raster)
library(terra)
library(dplyr)
library(stars)
library(readxl)
library(tmap)
library(mapedit)
library(tidyverse)
library(sf)
library(tinytex)
library(ggplot2)
```
##### Modèles de prévisions Météo-France
- SAFRAN (safran.gpkg)
- ALADIN63

***

### Fonctionnement de addition_gpkg : 
Elle prend en entrée une zone d'étude (x) ou demande une zone d'étude à l'opérateur, ainsi qu'une chaîne de caractères qui sera le nom du fichier GPKG de sortie. La fonction renverra ensuite une carte des aléas et des enjeux qui définissent le risque d'incendie. Cela est rendu possible grâce à plussieurs sous-fonctions dont les données sont majoritairement importées via Happign. Les données DRIAS ne pouvant pas être lues directement sur RStudio et n'existant sous Happign, il a fallu installer le package SAFRAN (safran.gpkg), un modèle de Météo-France qui permet de reconstituer les conditions météorologiques, ainsi qu'ALADIN63, un modèle Météo-France de prévision météorologique.

