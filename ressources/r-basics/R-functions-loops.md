*Auteur : Valentin Mathieu - Dernière mise à jour 02 Septembre 2024*

***

# Introduction à la programmation fonctionnelle - S'épargner de nombreux copier-coller

<!-- :240903:gf:r:enseignement: -->

## Écrire des fonctions

Si vous avez appris à importer des données dans RStudio, à les formater et à les manipuler, à écrire des scripts et des rapports Markdown, à créer de beaux graphiques informatifs à l'aide de ggplot2, cela signifie que vous disposez de tous les outils de base pour effectuer une analyse simple des données à l'aide de R.

Cependant, au fur et à mesure que vous travaillez sur votre projet, il se peut que vous souhaitiez répéter plusieurs fois la même action. Par exemple, vous pouvez vouloir créer plusieurs graphiques qui ne diffèrent que par la saisie des données. La tentation est grande de copier et coller le code plusieurs fois dans le script, en changeant à chaque fois le jeu de données d'entrée, mais tous ces copier-coller augmentent le risque d'erreur, et cela signifie aussi que si vous voulez changer un élément commun de ces morceaux de code copiés, vous devrez modifier chaque morceau individuellement.

On va ici s'intéresser au concept de fonctions et de boucles dans R comme une méthode permettant de minimiser le besoin de copier et de coller des morceaux de code, ce qui contribue à rendre votre code plus efficace et plus lisible et à minimiser le risque de faire des erreurs en retapant manuellement le code. Ce tutoriel explique également comment utiliser efficacement les fonctions dans votre code et donne une introduction plus formelle à la programmation fonctionnelle en tant que style de codage.

**R est un langage de programmation fonctionnelle à la base. Lorsque vous exécutez une commande sur des données, par exemple `sum(1, 2)`, sum est une fonction. En fait, tout ce que vous faites dans R implique au moins une fonction. Tout comme le langage R de base et les autres packages R contiennent des fonctions, vous pouvez également écrire vos propres fonctions pour effectuer diverses tâches en utilisant les mêmes outils que les développeurs de packages, et ce n'est pas aussi difficile que cela en a l'air.**

## Construction d'une fonction simple

Ouvrez une nouvelle session RStudio et créez un nouveau script R. Si vous ne l'avez pas encore fait, téléchargez les ressources nécessaires à ce tutoriel à partir de [ce dépôt Github](https://github.com/ourcodingclub/CC-5-fun-and-loop). Ces ressources sont mises à disposition par le Coding Club pour [le tutoriel](https://ourcodingclub.github.io/tutorials/funandloops/). Clonez et téléchargez le dépôt sous forme de fichier zip, puis décompressez-le. Dans votre script R, définissez le répertoire de travail sur le dépôt que vous venez de télécharger en exécutant le code ci-dessous (en remplaçant `PATH_TO_FOLDER` par l'emplacement du dossier sur votre ordinateur, par exemple `~/Downloads/CC-5-fun-and-loop`) :

```{r, eval=FALSE}
setwd("PATH_TO_FOLDER")
```

Importons quelques données du dépôt téléchargé que nous pourrons utiliser pour tester la fonction :

```{r, eval=FALSE}
trees_bicuar <- read.csv("trees_bicuar.csv")
trees_mlunguya <- read.csv("trees_mlunguya.csv")
```

Les données contiennent des informations sur les tiges d'arbres étudiées dans quatre parcelles de 1 ha sur des sites de terrain en Afrique australe. `trees_bicuar` contient des données sur les arbres du parc national de Bicuar dans le sud-ouest de l'Angola, et `trees_mlunguya` contient des données sur les arbres du sud du Mozambique. Chaque tige d'arbre d'un diamètre de tronc supérieur à 5 cm a été mesurée pour la hauteur et le diamètre du tronc, et identifiée en fonction de l'espèce.

Jetez un coup d'œil au contenu de trees_bicuar avant de poursuivre :

```{r, eval=FALSE}
head(trees_bicuar)
str(trees_bicuar)
```

La syntaxe de base pour créer une fonction est la suivante :

```{r, eval=FALSE}
example.fn <- function(x, y){
    # Perform an action using x and y
    x + y
}
```

**La commande `function()` est utilisée pour indiquer à R que nous créons une fonction, et que nous assignons la fonction à un objet appelé `example.fn`. `x` et `y` sont les « arguments » de la fonction, c'est-à-dire les éléments que l'utilisateur fournit lors de l'exécution de la fonction, puis entre les crochets sont les actions effectuées par la fonction, en utilisant les paramètres définis par l'utilisateur plus tôt dans l'appel de la fonction, et tout autre objet dans l'environnement de travail - dans ce cas, l'addition de `x` et de `y`.

Exécutez le code ci-dessus pour créer la fonction, puis testez-la :

```{r, eval=FALSE}
example.fn(x = 1, y = 2)
```

Vous devriez obtenir la valeur 3, car la fonction `exemple.fn()` a reçu les valeurs `x = 1` et `y = 2`, qui ont ensuite été transmises à la fonction, qui a effectué l'opération `x + y`. Notez que la convention consiste à nommer une fonction en utilisant `.` plutôt que `_`, qui est normalement utilisé pour définir des objets de données. Ce n'est pas une règle, mais il est préférable de s'en tenir aux conventions utilisées par d'autres programmeurs pour garder les choses cohérentes.

`exemple.fn()` est une fonction très simple, mais vos fonctions peuvent être aussi simples ou complexes que vous le souhaitez. Par exemple, nous pouvons également définir une fonction qui calcule la surface basale/terrière de chaque tige en m<sup>2</sup> à partir du diamètre, qui est en cm. La surface terrière est la surface de la section transversale du tronc de l'arbre s'il était coupé parallèlement au sol.

```{r, eval=FALSE}
basal.area <- function(x){
	(pi*(x)^2)/40000
}
```

Cette fonction a une entrée, `x`. `x` peut être un vecteur numérique ou une colonne numérique dans un tableau de données, en fait tout ce qui ne provoque pas d'erreur dans le corps de la fonction. Le corps de la fonction multiplie `x^2` par `pi`, puis divise par `40 000`, ce qui donne la surface de base en sortie.

Testez la fonction en fournissant la colonne diamètre des données sur les troncs d'arbres de Bicuar (`trees_bicuar$diam`) pour voir ce qu'elle donne en sortie :

```{r, eval=FALSE}
basal.area(x = trees_bicuar$diam)
```

Les arguments de la fonction n'ont pas besoin d'être appelés `x` et `y`, ils peuvent être n'importe quelle chaîne de caractères. Par exemple, la fonction ci-dessous fonctionne de la même manière que la précédente, sauf que `x` est maintenant appelé `dbh` :

```{r, eval=FALSE}
basal.area <- function(dbh){
	(pi*(dbh)^2)/40000
}
```

En outre, vous pouvez ajouter un nombre indéterminé d'arguments supplémentaires à l'aide de l'opérateur `...`. Imaginons que nous souhaitions étendre notre fonction `basal.area()` afin qu'elle puisse calculer la surface basale combinée de plusieurs vecteurs de mesures de diamètre, provenant par exemple de plusieurs sites :

```{r, eval=FALSE}
basal.area <- function(...){
    (pi*c(...)^2)/40000
}

basal.area(trees_bicuar$diam, trees_mlunguya$diam)
```

Tout comme une fonction normale, la sortie de `basal.area()` peut être affectée à un nouvel objet, par exemple une nouvelle colonne dans `trees_bicuar` :

```{r, eval=FALSE}
trees_bicuar$ba <- basal.area(dbh = trees_bicuar$diam)
```

L'écriture de fonctions pour des opérations simples comme l'exemple ci-dessus est utile si vous voulez effectuer la même opération plusieurs fois dans un script et que vous ne voulez pas copier et coller le même code (par exemple `(pi*(dbh)^2)/40000)` plusieurs fois, ce qui réduit les risques de faire une faute de frappe lors du copier et coller.

## Les fonctions dans les boucles

Nous avons vu comment écrire une fonction et comment elle peut être utilisée pour créer des opérations concises et réutilisables qui peuvent être appliquées plusieurs fois dans un script sans avoir à les copier-coller, mais là où les fonctions prennent tout leur sens, c'est lorsqu'elles sont combinées à des procédures en boucle. Les boucles servent à exécuter la même opération sur un groupe d'objets, ce qui minimise encore la réplication du code.

Les boucles se présentent sous deux formes principales dans R : les boucles `for()` et les boucles `while()`. Ici, nous nous concentrerons sur les boucles `for()`, qui sont généralement plus faciles à lire que les boucles `while()`, et qui peuvent être utilisées pour effectuer les mêmes types d'actions. Les boucles `while()` sont principalement utilisées lorsque l'utilisateur souhaite effectuer une action un certain nombre de fois, alors qu'une boucle `for()` est généralement utilisée lorsque l'utilisateur souhaite effectuer une action sur un ensemble d'objets nommés.

Une boucle `for()` parcourt un certain nombre d'éléments, le plus souvent stockés sous la forme d'une liste, et effectue une action identique sur chaque élément. Elle permet de réduire considérablement le nombre de copier-coller.

La syntaxe de base pour créer une boucle `for()` est la suivante :

```{r, eval=FALSE}
for(i in list){
    # PERFORM SOME ACTION
}
```

Imaginez que vous ayez plusieurs sites de terrain, chacun avec quatre parcelles de 1 Ha avec les mesures de tiges d'arbres décrites précédemment. Les données de chaque site de terrain sont contenues dans un data frame différent, par exemple `arbres_bicuar` et `arbres_mlunguya`. Si nous voulions calculer la surface terrière de toutes les tiges sur les deux sites, nous pourrions exécuter :

```{r, eval=FALSE}
trees_bicuar$ba <- basal.area(trees_bicuar$diam)
trees_mlunguya$ba <- basal.area(trees_mlunguya$diam)
```

Ce qui précède semble correct pour l'instant, mais que se passerait-il si nous avions 100 sites de terrain au lieu de deux ? Dans ce cas, vous pouvez utiliser une boucle `for()`. Tout d'abord, nous devons créer une liste de data frame sur lesquelles la boucle sera exécutée. Il existe de nombreuses façons de procéder, mais la plus simple est la suivante :

```{r, eval=FALSE}
trees <- list("trees_bicuar" = trees_bicuar, "trees_mlunguya" = trees_mlunguya)
```

Il en résulte une liste appelée `trees`, où chaque élément de la liste est un data frame. Les éléments d'une liste peuvent être accédés à l'aide de doubles crochets, par exemple `trees[[1]]` sélectionne le premier élément de la liste, le dataframe pour `trees_bicuar`. Nous pouvons tirer parti de cette méthode d'indexation des listes à l'aide de crochets lorsque nous construisons notre boucle `for()` :

```{r, eval=FALSE}
for( i in 1:length(trees) ){
	trees[[i]]$ba <- basal.area(trees[[i]]$diam)
}
```

La première ligne met en place la boucle, de la même manière que la définition de `function()` a fonctionné plus tôt. `1:length(trees)` crée une séquence d'entiers de 1 à la longueur de la liste `trees`, donc dans ce cas la séquence sera 1, 2 puisqu'il y a deux éléments de liste. `i` prendra chaque valeur de `1:length(trees)` à tour de rôle, puis exécutera les actions dans les crochets une fois. Par exemple, la première fois que la boucle s'exécute, `i` aura une valeur de `1`, et la deuxième fois, `i` aura une valeur de `2`. Une fois que la boucle s'est exécutée pour la deuxième fois, la boucle se termine, car il n'y a plus de valeurs dans `1:length(trees)`.

Le corps de la boucle crée une nouvelle colonne dans chaque cadre de données de la liste, puis exécute la fonction `basal.area()` en utilisant la colonne `diam` du même cadre de données comme entrée. Ainsi, la première fois que la boucle s'exécute, elle crée une nouvelle colonne appelée `ba` dans le premier élément de la liste `trees`, `trees[[1]]`.

L'exemple ci-dessus illustre le fonctionnement des boucles, mais souvent, les données ne sont pas séparées dans plusieurs cadres de données dès le départ, mais plutôt dans un seul cadre de données avec une colonne pour regrouper les différents ensembles de données.

En revenant à l'ensemble de données `trees_mlunguya`, vous pouvez voir qu'il y a une colonne appelée `year`, qui indique quand chaque mesure de tige a été prise. Imaginons que nous voulions effectuer le calcul de la surface terrière pour chaque année de l'ensemble de données, puis déterminer si la surface terrière moyenne des tiges dans les parcelles a changé au fil des ans. Nous pouvons le faire à l'aide d'une boucle `for()`.

Tout d'abord, séparez `trees_mlunguya` en une liste de data frame, chacune basée sur le contenu de la colonne année :

```{r, eval=FALSE}
trees_mlunguya_list <- split(trees_mlunguya, trees_mlunguya$year)
```

Ensuite, lancez une boucle `for()` pour remplir une liste vide avec la surface terrière moyenne de chaque année :

```{r, eval=FALSE}
# Create an empty list
mean_ba_list <- list()

for( i in 1:length(trees_mlunguya_list) ){
	ba <- basal.area(trees_mlunguya_list[[i]]$diam)
	mean_ba <- mean(ba)
	year <- mean(trees_mlunguya_list[[i]]$year)
	dat <- data.frame(year, mean_ba)
	mean_ba_list[[i]] <- dat
}
```

À chaque itération, cette boucle crée un certain nombre d'objets de données intermédiaires (`ba`, `mean_ba`, `year`) et renvoie finalement un data frame (`dat`) avec une seule ligne et deux colonnes, l'une pour l'année et l'autre pour la surface terrière moyenne. Chacune de ces images de données est ensuite stockée en tant qu'élément de liste dans la nouvelle liste `mean_ba_list`.

Bien entendu, ce calcul intermédiaire pourrait être stocké dans sa propre fonction personnalisée :

```{r, eval=FALSE}
ba.mean.year <- function(dbh, year){
	data.frame(
        mean_ba = mean(basal.area(dbh)),
        year = mean(year)
    )    
}

ba.mean.year(trees_mlunguya_list[[1]]$diam, trees_mlunguya_list[[1]]$year)
```

Cette nouvelle fonction peut être utilisée dans la boucle `for` :

```{r eval=FALSE}
for( i in 1:length(trees_mlunguya_list) ){
	mean_ba_list[[i]] <- ba.mean.year(
		trees_mlunguya_list[[i]]$diam,
		trees_mlunguya_list[[i]]$year)
}
```

Notez que cette boucle `for()` contient maintenant une fonction personnalisée (`ba.mean.year()`), qui contient elle-même une fonction personnalisée (`basal.area()`), ce qui démontre qu'il n'y a vraiment aucune limite à la complexité que vous pouvez créer avec des outils de programmation fonctionnelle tels que les boucles et les appels de fonction. Vous pouvez même avoir des boucles dans les boucles et des boucles dans les fonctions !

## Fonctions de la famille `lapply()`

Les boucles `for()` sont très utiles pour parcourir rapidement une liste, mais comme R préfère tout stocker en tant que nouvel objet à chaque itération de la boucle, les boucles peuvent devenir très lentes si elles sont complexes ou si elles exécutent de nombreux processus et de nombreuses itérations. `lapply()` et plus généralement la famille de fonctions `apply` peuvent être utilisées comme alternative aux boucles. `lapply()` exécute des opérations sur des listes d'éléments, de la même manière que les boucles `for()` ci-dessus. Pour reproduire la boucle `for()` précédente, dans laquelle nous avons calculé la surface terrière moyenne par année dans `trees_mlunguya`, vous pouvez exécuter :

```{r, eval=FALSE}
lapply(trees_mlunguya_list, function(x){ba.mean.year(dbh = x$diam, year = x$year)})
```

Le premier argument de `lapply()` donne l'objet `list` à parcourir. Le deuxième argument définit une fonction sans nom, où `x` sera remplacé par chaque élément de la liste au fur et à mesure que `lapply()` les parcourt. Le code entre les crochets est la fonction sans nom, qui contient elle-même notre fonction personnalisée `ba.mean.year()`.

En plus d'être légèrement plus rapide que la boucle `for()`, on peut dire que lapply est également plus facile à lire qu'une boucle `for()`.

Pour illustrer une autre façon d'utiliser `lapply()`, imaginons que nous voulions trouver la hauteur moyenne des arbres dans `trees_bicuar` pour chaque famille taxonomique.

Tout d'abord, créez une liste de vecteurs de hauteur (plutôt que des dataframes), chaque liste représentant une famille d'espèces différente.

```{r, eval=FALSE}
bicuar_height_list <- split(trees_bicuar$height, trees_bicuar$family)
```

Exécutez ensuite `lapply()` :

```{r, eval=FALSE}
lapply(bicuar_height_list, mean, na.rm = TRUE)
```

Remarquez que nous n'avons pas eu besoin d'utiliser des crochets ou une fonction anonyme, mais que nous avons simplement passé mean comme deuxième argument de `lapply()`. J'ai également fourni un argument à `mean()` en le spécifiant simplement après (`na.rm = TRUE`).

Je pourrais utiliser `sapply()` pour obtenir une sortie plus lisible de cette boucle. `sapply()` simplifie la sortie de `lapply()` en un vecteur, dont les éléments sont nommés en fonction du nom des éléments de la liste originale :

```{r, eval=FALSE}
sapply(bicuar_height_list, mean, na.rm = TRUE)
```

`sapply()` ne pourra pas simplifier la sortie de chaque boucle `lapply()`, surtout si la sortie est complexe, mais pour cet exemple, où nous n'avons qu'un seul nombre décimal nommé, `sapply` fonctionne bien.

## Instructions conditionnelles

Une autre technique de programmation fonctionnelle utile consiste à utiliser des instructions conditionnelles pour modifier l'exécution du code en fonction de certaines conditions. Cela signifie que vous pouvez créer des fonctions plus complexes qui peuvent être appliquées dans un plus grand nombre de situations.

Par exemple, dans les données `trees_bicuar`, une colonne fait référence à la méthode de mesure de la hauteur des `trees_bicuar`, appelée `trees_bicuar$height_method`. Un groupe d'assistants de terrain a mesuré la hauteur des arbres à l'aide d'un long bâton, tandis que les autres avaient accès à un télémètre laser, ce qui a eu une incidence sur la précision des mesures. Les mesures prises à l'aide d'un bâton étaient généralement inférieures d'environ 1 m à la hauteur réelle de l'arbre, tandis que les mesures effectuées à l'aide du scanner laser ne sont certifiées précises qu'à +/- 0,1 m. Une correction simple consisterait donc à ajouter 1 m à chaque mesure effectuée à l'aide d'un bâton, et à arrondir chaque mesure effectuée à l'aide du laser au 0,1 m le plus proche.

La « hauteur moyenne de Lorey » est une mesure forestière couramment utilisée pour évaluer la croissance d'une parcelle forestière au fil du temps. La hauteur moyenne de Lorey est calculée en multipliant la hauteur de l'arbre par la surface terrière de l'arbre, puis en divisant la somme de ce calcul par la surface terrière totale de la parcelle. Nous pouvons construire une fonction qui mesure la hauteur moyenne de Lorey pour chaque placette, mais nous voulons ajuster les estimations de hauteur en fonction de la méthode utilisée. Pour ce faire, nous pouvons utiliser une instruction `ifelse()`.

En principe, une instruction `ifelse()` teste une condition logique TRUE/FALSE dans les données, puis exécute l'une des deux actions en fonction du résultat du test. Par exemple, « si la valeur de x est supérieure à 2, multipliez-la par 2, sinon, divisez-la par 2 ». Le code ci-dessous construit une fonction avec une instruction `ifelse()` pour calculer la hauteur moyenne de Lorey pour les placettes de Bicuar.

```{r, eval=FALSE}
stick.adj.lorey <- function(height, method, ba){
	height_adj <- ifelse(method == "stick", height + 1, round(height, digits = 1))

	lorey_height <- sum(height_adj * ba, na.rm = TRUE) / sum(ba, na.rm = TRUE)

	return(lorey_height)
}
```

Nous pouvons ensuite tester la fonction sur chaque parcelle en utilisant `lapply()` comme nous l'avons fait précédemment :

```{r, eval=FALSE}
trees_bicuar_list <- split(trees_bicuar, trees_bicuar$plotcode)

lapply(trees_bicuar_list, function(x){stick.adj.lorey(height = x$height, method = x$height_method, ba = x$ba)})
```

Les instructions `ifelse()` peuvent également être utilisées en conjonction avec des arguments de fonction logiques TRUE/FALSE pour déterminer si certaines actions sont effectuées. Par exemple, nous pouvons écrire une fonction qui calcule des statistiques sommaires sur les mesures du diamètre des troncs pour un champ donné, et nous pouvons utiliser des arguments TRUE/FALSE pour permettre à l'utilisateur de décider si certaines statistiques sont calculées :

```{r, eval=FALSE}
diam.summ <- function(dbh, mean = TRUE, median = TRUE, ba = TRUE){
		mean_dbh <- ifelse(mean == TRUE, 
			mean(dbh), 
			NA)
		median_dbh <- ifelse(median == TRUE, 
			median(dbh), 
			NA)
		mean_ba <- ifelse(ba == TRUE, 
			mean(basal.area(dbh)), 
			NA)
		
		return(as.data.frame(na.omit(t(data.frame(mean_dbh, median_dbh, mean_ba)))))
}

diam.summ(dbh = bicuar_trees$diam, mean = TRUE, median = FALSE)
```

Notez également que dans cette définition de fonction, les arguments supplémentaires ont des valeurs par défaut, par exemple `mean = TRUE`. Cela signifie que même si l'utilisateur ne précise pas la valeur de la moyenne, par exemple `diam.summ(dbh = trees_bicuar$diam, median = TRUE, mean_ba = FALSE)`, R prendra par défaut la valeur de `mean = TRUE`, calculant ainsi le diamètre moyen du tronc.

***