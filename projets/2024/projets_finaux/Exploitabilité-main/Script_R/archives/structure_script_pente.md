Agnès Davière 10/09/2024  
Structure du script pentes MNT

# FONCTION PRINCIPALE
## Entrée  
-	Code postale  : caractères  
-	Libelle commune : caractères  
-	N° section : caractères  
-	N° parcelle : caractères 
  
## Sortie  
-	Fichier geopackage avec les couches suivantes :  
 	o	Cadastre non corrigé (vecteur)  
 	o	Pentes catégorisées (raster)  

# FONCTIONS INTERMEDIAIRES
## Etape 1 : travail sur une seule parcelle d’une seule commune. Ex : Parcelle 2594, section 0A à Salex. 
-	code_insee : OK  
  o	Entrée : code postaux et libellés des communes (chaînes de caractères)  
 	o	Sortie : code insee de la commune  

-	get.cadastre : OK  
  o	Entrée : code insee + n° de section + n° de parcelle  
 	o	Sortie : limites cadastrales de la parcelle concernée, format vecteur  

-	get.mnt : Ok sans le buffer pour le moment  
  o	Entrée : couche cadastre format vecteur  
 	o	Sortie : mnt format raster avec un buffer de 100m autour de la parcelle considérée  
 	
-	pente :  OK  
  o	Entrée : mnt format raster  
 	o	Sortie : raster de pentes catégorisées  

-save.raster.gpkg: OK  
 o	Entrée : SpatRaster  
 o	Sortie : raster enregistré au nom du SpatRaster dans un gpkg 'pente.gpkg"     

 -save.sf.gpkg: OK  
 o	Entrée : SpatVector  
 o	Sortie : vecteur enregistré au nom du SpatVector dans un gpkg 'pente.gpkg"  

-	save.gpkg : OK  
  o	Entrée : un SpatRaster et un sf  
 	o	Sortie : un géopackage comprenant les deux couches    

# FONCTIONS TEMPORAIRES EN DEHORS DU SCRIPT :  
-	draw :  OK  
  o	Entrée : 1 couche format vecteur, 1 couche format raster  
 	o	Sortie : plot dynamique des couches  
--> Pas dans le script final !  


