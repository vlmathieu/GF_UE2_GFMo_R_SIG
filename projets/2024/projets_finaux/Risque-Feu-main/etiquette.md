# Règles d'utilisation des scripts en commun
# Organisation des scripts en section ----
définir un commentaire en ajoutant # + espace au début de n'importe quelle ligne et en tapant du texte après, par exemple # fonction desserte. Sous ce commentaire, écriture du code

# Structure du script : règles adaptées selon nos besoins
Toutes les packages et les libraries sont exposées au début du code. Aucun package ne devra figurer dans les sous-fonctions
Il est par ailleurs nécessaire de créer une section en utilisant quatre ou plus - à la fin d'une ligne de commentaire, une petite flèche apparaît dans la marge à côté du commentaire. En cliquant sur ces flèches, on peut réduire la section, utile pour parcourir un long texte.

Fonctions : les fonctions écrites par tous les membres du groupe doivent être absolument définies. Il s'agit d'expliquer ce que renvoient et à quoi servent les sous-fonctions.

Importation de données : quelles données utilisez-vous et où sont-elles stockées ? La ligne de code permettant d'importer des données nécessite d'être suffisement explicite sur la nature et la source des données.

# Etiquette de syntaxe de codage
Ne pas appeler les objets par un nom vague. Les noms doivent être précis et évoquer le plus aisément ce que représente l'objet dans la réalité.
Les noms d'objets, de variables (par exemple object$variable) et de fonctions doivent être en minuscules.

Les noms de variables doivent être des substantifs, par exemple inflammabilite ou combustibilite.

Utiliser un trait de soulignement pour séparer les mots dans un fichier de script.
La forme préférée pour les noms d'objets/variables est celle de lettres minuscules et de mots séparés par des traits de soulignement, par exemple (nom_objet$nom_variable).
Concernant les espaces, ils ont été placés autour de tous les opérateurs infixes (=, +, -, <-, etc.). La même règle s'applique à l'utilisation de = dans les appels de fonction. Il faut toujours mettre un espace après une virgule, et jamais avant !!!
Deux exceptions pour cette règle : et :: n'ont pas besoin d'être entourés d'espaces et il ne faut pas ajouter d'espaces lors de la définition des systèmes de coordonnées dans les objets spatiaux.
Il ne faut pas placer d'espace avant les parenthèses gauches, sauf dans un appel de fonction.
Ne pas mettre d'espace autour du code entre parenthèses ou entre crochets.

Pour les accolades ouvrantes, celle-ci ne doit jamais être placée sur sa propre ligne et doit toujours être suivie d'une nouvelle ligne. Une accolade fermante doit toujours être placée sur sa propre ligne, à moins qu'elle ne soit suivie d'une autre ligne. Le code à l'intérieur des accolades doit toujours être indenté.
Longueur de la ligne : ne pas dépasser 80 caractères par ligne autant que possible (convention officielle).
Lors de l'utilisation des pipes du package dplyr, il faut garder l'opérateur de pipe %>% à la fin de la ligne et continuer le pipe sur une nouvelle ligne.




