*Auteur : Valentin Mathieu - Dernière mise à jour 02 Septembre 2024*

***

# Projets R/SIG pour l'UE GF_UE2_GFMo, cours "Rappels R et SIG", 2024-2025

<!-- :240903:gf:r:enseignement: -->

Chaque projet détaillé ci-dessous est catégorié selon sa faisabilité ou son caractère prospectif. Peu importe le projet choisi, il n'y a pas d'obligation de résultats. L'important est de produire un travail sérieux vous faisant manipuler les notions vues en cours et en TD.

## Sujet 1

Sujet catégorisé "possible".

Sujet : Analyse sur une zone buffer des placettes IFN avec calcul de l'accroissement moyens et courants par essences/catégories de diamètre.

Quelques pistes de réflexion sur la démarche :

-	Récupération automatique des données IFN : deux solutions :
    + {happifn} : package développé par Paul Carteron pour récupérer les données brutes de l’IFN. Il est couplé avec un autre package {happifndata} contenant les données de sylvoécorégion, régions forestières, … (plus d’infos ici : [Getting started with happifn • happifn (paul-carteron.github.io)](https://paul-carteron.github.io/happifn/articles/getting_started.html))
    + {FrenchNFIfindeR} : un package de Jeremy Borderieux, un ancien doctorant AgroParisTech qui permet de télécharger et de retraiter les données (bien lire la documentation en amont) ([Jeremy-borderieux/FrenchNFIfindeR: Get and format French National Forest Inventory data (github.com)](https://github.com/Jeremy-borderieux/FrenchNFIfindeR))
    + Dans les deux cas, le point de départ pour récupérer manuellement la donnée est ici : [DataIFN (ign.fr)](https://inventaire-forestier.ign.fr/dataifn/)

-	L’idée du projet de partir des données brutes et des métadonnées pour faire les bonnes jointures et intersection spatiale pour obtenir un accroissement par essence sur une zone donnée.

-	Les données IFN sont assez complexe à prendre en main. Bien prendre le temps d'étudier les données.

-	L’objectif finale est de produire des méthodes/fonctions permettant d’extraire certaines métriques de donnée IFN (en mode exploratoire). Ces fonctions pourront d’ailleurs être ajoutée au package {happifn} par la suite.

## Sujet 2

Sujet catégorisé "Prospectif".

Sujet : Analyse des données Drias et Météo France du risque incendie

Quelques pistes de réflexion : Explorez les données Diras et Météo France pour étudier dans quelles mesures elles peuvent être utiles pour cartographier le risque incendie dans une zone donnée. Cela impliquera de comprendre comment le risque incendie est défini et caractérisé, comment il est mesuré, et comment ces données peuvent être combinées (ou non) avec d'autres pour la gestion forestière.

## Sujet 3

Sujet catégorisé "Prospectif".

Sujet : Recherche et récupération automatique des Enjeux patrimoniaux (Monuments historiques, sites inscrits, classés) en lien avec l'atlas du patrimoine

Quelques pistes de réflexion :
- Le package happign permet de se connecter au Géoportail de l’Urbanisme avec get_apicarto_gpu. Plusieurs exemples d’utilisation ici : [API Carto • happign (paul-carteron.github.io)](https://paul-carteron.github.io/happign/articles/web_only/api_carto.html#api-carto-urbanism).

    + L’idée global est la suivante : Vérifier qu’une commune à bien un PLU sur le géopportail de l’urbanisme puis le télécharger et décortiquer le jeu de données pour trouver des infos intéressantes pour l’aménagement forestier (alignement d’arbre, zone à enjeux, monuments historiques, …)

    + Également, il est possible d’accéder à la donnée par QGIS : [Services - Géoportail de l'Urbanisme (geoportail-urbanisme.gouv.fr)](https://www.geoportail-urbanisme.gouv.fr/services/).

    + L’objectif final est donc : de récupérer la donnée avec QGIS ou happign, comprendre comment la donnée est structuré, trier les infos nécessaires, intersecter les données avec une zone d’étude.

## Sujet 4

Sujet catégorisé "Possible".

Sujet : Récupération automatique des aires naturelles, des habitats et espèces remarquables et des DOCOB

Quelques pistes de réflexion :
- Pour la récupération des aires naturelles, c’est possible avec happign directement. S’ils regardent bien la vignette [happign for foresters • happign (paul-carteron.github.io)](https://paul-carteron.github.io/happign/articles/web_only/happign_for_foresters.html) le code est même déjà fait. Les données peuvent être complété à partir du site de l’INPN s’il n’y a pas tout : [INPN - Cartes et informations géographiques (mnhn.fr)](https://inpn.mnhn.fr/telechargement/cartes-et-information-geographique) (en tout cas comparer les deux sources de données)
- Pour les DOCOB c’est une autre histoire, il faut réussir à les télécharger. C’est possible en fouinant le site de l’INPN mais il doit y avoir plus malin. Si les élèves arrivent à sortir une fonction qui détermine si un DOCOB existe et si oui le télécharge c’est déjà une belle prouesse.
- Si c’est trop facile, alors ils peuvent pousser en créant des fonction d’extraction de l’information des DOCOB

## Sujet 5

Sujet catégorisé "Possible". 

Sujet : Discrimination des surfaces par distance de débardage (par rapport à des infrastructures) et par analyses MNT (analyse pente)

- Happign permet de récupérer le MNT. S’agit ensuite de calculer la pente avec le package terra mais je crois que le résultat est assez moche. 

- Une autre solution est de passer par QGIS en téléchargeant en amont les données Raster et appliquer un traitement de pente au MNT.

- Comparer trois sources de MNT : BD ALTI, RGE ALTI, MNT recalculer avec les données LIDAR.

- Pour obtenir les routes forestières, là c’est vachement plus coton car on n’a pas de données sur ce sujet. On peut partir des données openstreet map et des routes IGN (j’ai un code qui traine à ce sujet si besoin) puis il faut manuellement repasser dessus pour valider les routes à garder.

- Ensuite, en définissant un buffer dépendant de la pente autour des routes, il est possible de caractériser l’exploitabilité de la forêt. En gros, il reproduise une partie du logiciel SylvAccess.

- Plutôt à réaliser sur QGIS ce projet

## Sujet 6

Sujet catégorisé "Possible/Prospectif".

Sujet : Etude d’impact du grand public sur un massif : 

Quelques pistes de réflexion :

- Récupération des données de routes, du nombre d’habitants par ville, des parkings, des aires touristiques, …. aux abords de la forêt et calcul d’isochrone/isodistance pour évaluer l’accessibilité à la forêt. Il faudra trouver une métrique un peu maline pour croiser toutes ces données.
    + L’idée est donnée une zone en entrée et d’avoir un ensemble de fonction qui va récupérer des infos tels que :
        + Les plus grandes villes dans un rayon de x kilomètres ; (happign)
        + Le nombre d’habitants totale dans un rayon de x kilomètre ;(happign)
        + Les infrastructures disponible comme des parkings aux abords des forêts, des aires de campings ; (openstreetmap). P. Carteron a des codes R qui permettent de récupérer ce type d’infos, notamment pour faire une carte des bars. Sinon, le travail d’exploration des packages R autour d’openstreetmap fais partie du boulot
    + Un autre étape est d’utiliser plutôt que de simple buffer autour de la forêt, des isochrone/isodistance. C’est toutes les zones accessibles à partir d’un point ou jusqu’à un point en x temp/ x mètre. Cela permet de prendre en compte la vitesse du déplacement en fonction de la voierie (autoroute vs route de campagne). L’ign propose se service ici [Service de calcul d'isochrones / isodistances | Géoservices (ign.fr)](https://geoservices.ign.fr/documentation/services/services-deprecies/isochrones). Happign permet d’accéder à ces API avec les fonction get_isodistance() et get_isochrone() (pour l’instant dans la version en développement du package). Elle possède beaucoup de paramètre avec lesquels les élèves peuvent jouer (voiture, pédestre / arrivée, départ / distance, temps)
- L’objectif final est de mettre au points (au moins) trois métriques décrivant la pression d’urbanisme que peut subir un forêt et de réaliser une carte automatique pour chacune de ces enjeux (par exemple, un carte des villes de plus de 10000 habitant pouvant atteindre le forêt en moins de 30min, …)


## Sujet 7 

Sujet catégorisé "Prospectif".

Sujet : Utilisation des données LIDAR récentes pour retrouver les cloisonnements sur un peuplement.

***