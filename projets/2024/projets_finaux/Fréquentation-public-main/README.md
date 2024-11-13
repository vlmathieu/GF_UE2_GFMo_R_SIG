**Projet sur la fréquentation des forêts publiques, à destination des gestionnaires**

*Contexte : pourquoi ce script*

  Une hausse de la fréquentation des forêts et une sensibilisation accrue des administrés aux enjeux environnementaux implique aujourd'hui, pour le gestionnaire, un changement de gestion sylvicole. Ce script permet d'adapter les coupes et travaux aux forêts les plus exposées au public, et, à l'échelle de la forêt, d'avoir une gestion différenciée aux abords des routes, parkings et points d'eau. 

*Ce que fait notre script*

 Ce script permet de connaître les parkings dans la forêt et à 500 m autour. 
A partir de ces parkings, des isochrones ont été tracées pour connaître toutes les villes de plus de 5000 habitants situées à 30 minutes en voiture. Les habitants de ces différentes villes ont été sommées, pour évaluer le nombre de visiteurs potentiels. 
L'impact des routes et des parkings a aussi été pris en compte. Trois zones ont été tracées en fonction de la distance à ces infrastructures. Cela permet au gestionnaire de connaitre les zones les plus exposées au public, mais aussi des connaître les zones du massif où la biodiversité est soumise à des pressions (sonores ou présence de déchets par exemple). 
Des Buffers ont aussi été tracés autour des points d'eau afin de mettre en avant les zones d'intérêt pour le public, devant ainsi faire l'objet d'une attention particulière. 

*Déroulement du code*

Partie 1 : Choix de la forêt par le gestionnaire. 

Partie 2 : Identification des villes de plus de 5000 habitants à proximité de la forêt, et classification de ces villes. 

![Carte_communes_periph](https://github.com/user-attachments/assets/65b0684a-528c-4b4c-bbf9-28f51c821a57)

Partie 3 : Identification des infrastructures à proximité et à l'intérieur de la forêt. 

![Carte_infrastructures_routes](https://github.com/user-attachments/assets/75c4157a-9c7b-434f-9913-fc22b3626ca7)

Partie 4 : Pression du grand public autour des parkings, grâce à des buffers. 

![Carte_pression_parking](https://github.com/user-attachments/assets/2fce9bd4-2d36-47c0-a8c2-cd0eb3a8d84b)

Partie 5 et 6 : Visualisation des sentiers et des points d'eau dans la forêt. 

Données de l'IGN:
![Carte_des_chemins_points_eau](https://github.com/user-attachments/assets/3c8884c3-0e96-42c4-82c2-14c3997c993b)

Comparaison avec les données disponibles sur OpenStreetMap.
![Carte_des_chemins_points_eau_OSM](https://github.com/user-attachments/assets/02ba1e8c-66b4-443b-bdab-eeafaab7ac29)

Partie 7 : Génération d'un fichier .gpkg pour obtenir une carte sur Qgis. 

