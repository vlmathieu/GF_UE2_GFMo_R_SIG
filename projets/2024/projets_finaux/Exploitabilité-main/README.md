# Sujet 5
## Projet-R-Desserte forestière
Sujet catégorisé "Possible".

Sujet : Discrimination des surfaces par distance de débardage (par rapport à des infrastructures) et par analyses MNT (analyse pente)

Happign permet de récupérer le MNT. S’agit ensuite de calculer la pente avec le package terra mais je crois que le résultat est assez moche.

Une autre solution est de passer par QGIS en téléchargeant en amont les données Raster et appliquer un traitement de pente au MNT.

Comparer trois sources de MNT : BD ALTI, RGE ALTI, MNT recalculer avec les données LIDAR.

Pour obtenir les routes forestières, là c’est vachement plus coton car on n’a pas de données sur ce sujet. On peut partir des données openstreet map et des routes IGN (j’ai un code qui traine à ce sujet si besoin) puis il faut manuellement repasser dessus pour valider les routes à garder.

Ensuite, en définissant un buffer dépendant de la pente autour des routes, il est possible de caractériser l’exploitabilité de la forêt. En gros, il reproduise une partie du logiciel SylvAccess.

Plutôt à réaliser sur QGIS ce projet

# Projet R desserte

1-	Trouver les données publiques sur la desserte, étudier les tables attributaires des shapes (données de l’IGN ou données OpenStreetMaps (package R existant)

2-	Travail sur la définition de l’accessibilité et donc créer des indices

3-	Déterminer des données d’entrées de la fonction : routes accessibles grumiers et routes accessibles skiddeur/porteur (données issues de OpenStreetMpas, IGN ou vectorisé sur ArcGis)

4-	Déterminer avec une fonction R les distances accessibles au porteur et au skkideur de part et d’autre de la route forestière

5-	Prendre en compte le MNT et calculer la pente avec le package terra de happign

6-	Créer une fonction qui fait des buffers de part de d’autres de la desserte en prennant en compte la pente

7-	En sortie : faire un raster et créer des indices d’exploitabilité (surface accessible /surface de forêt)

# Structuration du GitHub

## Nom des sccripts R

Les scripts R sont nommés de la manière suivante: annéemoisjour_sujet
Exemple: 20240909_mnt --> script créé le 09 septembre 2024, traitant du MNT. 
