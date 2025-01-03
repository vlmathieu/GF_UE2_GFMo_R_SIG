*Auteur : Valentin Mathieu - Dernière mise à jour 02 Septembre 2024*

***

# Quelques notions de base sur R

<!-- :240903:gf:r:enseignement: -->

## Vous connaissez R ?

R est un **langage de programmation statistique** qui a rapidement gagné en popularité dans de nombreux domaines scientifiques. 
R est également le nom du logiciel qui utilise ce langage pour le calcul statistique. 
Grâce à une vaste communauté d'assistance en ligne et à des packages dédiés qui fournissent des fonctionnalités supplémentaires 
pour pratiquement toutes les applications et tous les domaines d'étude, **il n'y a pratiquement rien que vous ne puissiez faire avec R**.

Si vous connaissez déjà des logiciels statistiques comme Minitab ou SPSS, 
la principale différence est que **R n'a pas d'interface utilisateur graphique**, 
ce qui signifie qu'il n'y a pas de boutons à cliquer ni de menus déroulants.
On peut le faire tourner depuis son terminal à travers plusieurs commandes. 
R peut être exécuté entièrement en tapant des commandes dans une interface texte 
(bienvenue dans la [Matrice](https://www.youtube.com/watch?v=pFS4zYWxzNA&pp=ygUGbWF0cml4) !). 
Cela peut sembler un peu intimidant, mais cela signifie aussi beaucoup plus de **flexibilité**, 
car vous ne dépendez pas d'une boîte à outils prédéterminée pour vos analyses,
et aussi, très important, une **reproductibilité** de vos analyses.

Si vous avez besoin d'être encore plus convaincu, 
pourquoi utiliser R et non l'un des nombreux autres logiciels statistiques tels que MATLAB, Minitab, ou même Microsoft Excel ? 
Eh bien, R est génial parce que :

- R est gratuit et open source, et le sera toujours ! Tout le monde peut utiliser le code et voir exactement comment il fonctionne.
- Comme R est un langage de programmation plutôt qu'une interface graphique, 
l'utilisateur peut facilement enregistrer des scripts sous forme de petits fichiers texte pour les utiliser ultérieurement, 
ou les partager avec des collaborateurs.
- R dispose d'une communauté en ligne très active et utile - 
il suffit généralement d'une recherche rapide pour découvrir que quelqu'un a déjà résolu le problème que vous rencontrez. 
Vous pouvez par exemple consulter les [liens utiles](https://ourcodingclub.github.io/links.html) du Coding Club !

Comme pour tout apprentissage d'une langue étrangère, il y a une courbe d'apprentissage, et c'est en pratiquant qu'on apprend.
Commençons !

**Remarque** : Une question qui pourrait venir à vos esprits est pourquoi R et pas un autre langage de programmation comme Python ou Julia ?
Répondre à cette question dépasse le cadre du cours. Nous dirons simplement qu'à partir du moment ou R a les outils pertinents pour la
gestion forestière et qu'il ne présente pas de limitation majeure pour des tâches typiques de gestion forestière nous n'aurons pas besoin
d'aller voir ailleurs.

## Télécharger R et RStudio

Comme nous l'avons dit précédemment, R n'a pas d'interface graphique en soi, 
mais la plupart des gens interagissent avec R par le biais de plates-formes graphiques qui offrent des fonctionnalités supplémentaires. 
Nous utiliserons un programme appelé **RStudio comme interface graphique de R**,
afin **d'accéder à nos scripts et à nos données, de trouver de l'aide et de prévisualiser les tracés et les résultats** en un seul endroit.

Vous pouvez télécharger R à partir de [CRAN (The Comprehensive R Archive Network)](https://cran.r-project.org/). 
Sélectionnez le lien correspondant à votre système d'exploitation.

Ensuite, téléchargez RStudio à partir du [site web de RStudio](https://www.rstudio.com/products/RStudio/) 
(sélectionnez la version libre et gratuite).

Si vous utilisez un Mac, en plus de R et RStudio, vous devez télécharger XQuartz ([disponible ici](https://www.xquartz.org/)).

Ouvrez RStudio. Cliquez sur « Fichier/Nouveau fichier/R script ».

![](../images/rstudio_panels.png)

Vous verrez maintenant une fenêtre comme celle ci-dessus. 
Vous pouvez taper du code directement dans la console en bas à gauche (cela ne veut pas dire que vous devez le faire* !). 
En appuyant sur la touche « Entrée » à la fin de la ligne, vous exécutez le code (essayez de taper `2 + 2` et de l'exécuter maintenant). 
Vous pouvez (devriez !) également écrire votre code dans le fichier script dans la fenêtre en haut à gauche. 
Pour exécuter une ligne de code à partir de votre script, appuyez sur `Ctrl+R` sous Windows ou sur `Cmd+Enter` sous Mac. 
Sur les ordinateurs Windows récents, le raccourci par défaut est `Ctrl+Entrée`. 
La fenêtre d'environnement vous donne un aperçu de votre espace de travail actuel**. 
Vous y verrez les données que vous avez importées, les objets que vous avez créés, les fonctions que vous avez définies, etc. 
Enfin, le dernier panneau comporte plusieurs onglets et affiche un aperçu de votre tracé. 
Il vous permet de naviguer dans les dossiers et de voir les paquets que vous avez actuellement installés et chargés.

*Une note sur les scripts (nous adorons les scripts !): Rappelez-vous que si vous entrez du code directement dans la console, 
il ne sera pas sauvegardé par R : il s'exécute et disparaît (bien que vous puissiez accéder à vos dernières opérations 
en appuyant sur la touche 'up' de votre clavier). En revanche, en tapant votre code dans un fichier script, 
vous créez un enregistrement reproductible de votre analyse. 
L'écriture de votre code dans un script est similaire à la rédaction d'un essai dans Word : 
il enregistre votre progression et vous pouvez toujours reprendre votre travail là où vous l'avez laissé ou y apporter des modifications. 
(N'oubliez pas de cliquer souvent sur Enregistrer `(Ctrl+S)`, afin de sauvegarder réellement votre script !)

Lorsque vous écrivez un script, il est utile d'ajouter des commentaires pour décrire ce que vous faites en insérant 
un hasthag # devant une ligne de texte. 
R verra tout ce qui commence par # comme du texte et non comme du code, et n'essaiera donc pas de l'exécuter, 
mais le texte fournira des informations précieuses sur le code à ceux qui liront votre script (y compris vous !). 
Comme tout écrit, les scripts bénéficient d'une structure et d'une clarté : nous en apprendrons plus sur 
[l'étiquette du codage](https://ourcodingclub.github.io/tutorials/etiquette/index.html) plus tard.

**Un petit mot sur l'espace de travail : L'espace de travail contient tout ce que vous avez utilisé au cours d'une session 
et qui flotte dans la mémoire de votre ordinateur. Lorsque vous quittez le programme, R vous demandera si vous souhaitez 
sauvegarder l'espace de travail actuel. Vous n'aurez [presque jamais besoin de le faire](https://www.r-bloggers.com/using-r-dont-save-your-workspace/), 
et il est préférable de cliquer sur non et de repartir à zéro à chaque fois. (Veillez cependant à sauvegarder votre script !!)

## À vos scripts

Conseil pour démarer : commencez par noter qui écrit, la date et l'objectif principal - 
dans notre cas, apprendre les bases de R. 
Voici un exemple que vous pouvez copier, coller et modifier dans votre nouveau texte :

```{r}
# DA Gestion Forestière AgroParisTec - Rappel sur R
# Apprendre à importer et à explorer des données et à créer des graphiques
# Écrit par Valentin Mathieu, UMR Silva, AgroParisTech, le 03/09/2024
```

Il est important d'avoir un petit texte explicatif du script en amont du code à executer pour permettre au lecteur de comprendre 
l'idée générale du script. Si je lis un scipt où il est précisé une date de création en 2015 et où aucune mise à jour n'est mentionnée,
je comprends que le script commence à dater et qu'il se peut qu'il ne tourne plus (évolution des packages, des fonctions...).

Il n'y a pas de règles sur la forme de ce paragraphe introduction : il vous est personnel. À vous de trouver un routine de description 
des scripts qui soit (i) constante d'un script à l'autre par soucis de constitante, (ii) pertinente en apportant les informations
nécessaires et importantes à mentionner au lecteur du script, (iii) relativement efficace (ce paragraphe ne doit être aussi long que le
code executable !).

Nous verrons lors de la découverte de GitHub que d'autres façon existe pour expliquer l'objectif de vos scripts à quelqu'un qui voudrait
reprendre votre travail (notamment le fameux fichier `readme.md`).

Les quelques lignes de code suivantes chargent généralement les packages dont vous aurez besoin pour votre analyse. 
Un package est un ensemble de commandes qui peuvent être chargées dans R pour fournir des fonctionnalités supplémentaires. 
Par exemple, vous pouvez charger un package pour formater des données ou pour créer des cartes. 
(Ou pour faire des graphiques avec des [chats dessus](https://github.com/Gibbsdavidl/CatterPlots), ou tout ce qui vous plaît... 
Comme nous l'avons dit précédemment, il n'y a pratiquement rien que vous ne puissiez pas faire !)

Pour installer un package, tapez `install.packages(« nom-du-package »)`. 
Vous n'avez besoin d'installer les packages qu'une seule fois, donc dans ce cas vous pouvez taper directement dans la console, 
plutôt que de sauvegarder la ligne dans votre script et de réinstaller le package à chaque fois.

Une fois le package installé, il suffit de le charger en utilisant `library(nom-du-paquet)`. 
Aujourd'hui, nous allons utiliser le [package](https://cran.r-project.org/web/packages/dplyr/index.html) `dplyr` 
qui fournit des commandes supplémentaires pour formater et manipuler les données. 
Le package dplyr peut s'avérer très puissant pour l'analyse de données, bien que des alternatives existent (le marché des packages sur R 
peut vite ressembler à un bazar marocain).

Les lignes de code suivantes doivent définir votre répertoire de travail ou working directory. 
Il s'agit d'un dossier de votre ordinateur dans lequel R recherchera des données, enregistrera vos tracés, etc. 
Pour faciliter votre travail, il est conseillé d'enregistrer tout ce qui concerne un projet au même endroit, 
car cela vous évitera de perdre du temps à taper des chemins d'accès ou à rechercher des fichiers 
qui ont été enregistrés dans un endroit connu de R. 
Par exemple, vous pouvez enregistrer votre script et toutes les données de ce cours dans un dossier. 
Par exemple, vous pouvez enregistrer votre script et toutes les données de ce tutoriel dans un dossier appelé « Intro_to_R ». 
(Il est conseillé d'éviter les espaces dans les noms de fichiers, car cela peut parfois perturber R.) 
Pour les projets plus importants, envisagez d'avoir un dossier racine portant le nom du projet (par exemple « My_Project ») 
comme répertoire de travail, et d'autres dossiers imbriqués à l'intérieur pour séparer les données, les scripts, les images, etc. 
(par exemple My_Project/Analysis_1/data, My_Project/Analysis_1/plots, My_Project/Analysis_2/data, etc.).
Une alternative que nous verrons et de créer un R project, très pratique pour mener un projet en solitaire, parfois moins pour
du travail collaboratif.

Pour savoir où se trouve votre répertoire de travail, exécutez le code `getwd()`. 
Si vous souhaitez le modifier, vous pouvez utiliser `setwd()`. 
Placez votre répertoire de travail dans le dossier où vous travaillez. 
Nous verrons comment faire en sorte de lier ce workind directory avec GitHub.

```{r, eval=FALSE}
install.packages("dplyr")
library(dplyr)
# Notez qu'il y a des guillemets lors de l'installation d'un package, mais pas lors de son chargement
# et n'oubliez pas que les hashtags vous permettent d'ajouter des notes utiles à votre code ! 

setwd("C:/User/CC-1-RBasics-master")
# Il s'agit d'un exemple de chemin d'accès, à modifier selon votre propre chemin d'accès.
```

**Attention !** Notez que sur un ordinateur Windows, le chemin d'accès à un fichier copié-collé comporte des barres obliques inverses 
séparant les dossiers (`"C\:dossier\données"`), alors que le chemin d'accès à un fichier que vous entrez dans R doit comporter des barres obliques 
inverses (`"C:/dossier/données"`).

## Importer et vérifier les données

Dans RStudio, pour importer des données (sous forme de fichier `.csv`), vous pouvez soit cliquer sur le bouton Import dataset 
et naviguer jusqu'à l'endroit où vous avez enregistré votre fichier, soit utiliser la commande `read.csv()`. 
Si vous utilisez le bouton, une fenêtre s'ouvrira pour afficher un aperçu de vos données. 
Assurez-vous qu'à côté de *Heading* vous avez sélectionné *Yes* (cela indique à R de traiter la première ligne de vos données 
comme les noms des colonnes) et cliquez sur *Import*. 
Dans la console, vous verrez le code de votre importation, qui comprend le chemin d'accès au fichier - 
il est conseillé de copier ce code dans votre script, afin de savoir à l'avenir d'où provient votre ensemble de données.

![](../images/rstudio_import.png)

R fonctionne mieux avec les fichiers `.csv` (comma separated values). 
Si vous avez saisi vos données dans Excel, vous devez cliquer sur *Enregistrer* sous et sélectionner `csv` comme extension de fichier. 
Lorsque vous saisissez des données dans Excel, ne mettez pas d'espaces dans vos noms de lignes, car ils perturberont R par la suite 
(par exemple, choisissez quelque chose comme `height_meters` plutôt que `height (m)`). 
Certains ordinateurs enregistrent les fichiers `.csv` avec des points-virgules `;`, et non des virgules `,` comme séparateurs. 
Cela se produit généralement lorsque l'anglais n'est pas la première ou la seule langue de votre ordinateur. 
Si vos fichiers sont séparés par des points-virgules, utilisez `read.csv2` au lieu de `read.csv`, ou utilisez l'argument "sep" (pour séparateur) 
dans la fonction `read.csv` : `r.csv("votre-chemin-de-fichier", sep = ";"")`.

```{r, eval=FALSE}
my_data <- read.csv("path/to/file/file.csv") 
```

N'oubliez pas de sauvegarder votre script de temps en temps ! 
Si vous ne l'avez pas encore enregistré, pourquoi ne pas le faire dans le même répertoire que le reste du fichier du didacticiel, 
et lui donner un nom significatif.

Une remarque sur les objets : R est un langage basé sur les objets, ce qui signifie que les données que vous importez 
et toutes les valeurs que vous créez ultérieurement sont stockées dans des objets que vous nommez. 
La flèche `<-` dans le code ci-dessus représente la manière dont vous affectez les objets. 
Ici, nous avons attribué notre fichier csv à l'objet `my_data`. 
Nous aurions tout aussi bien pu l'appeler `mydata` ou `hello` ou `inventaire_sologne_campagne2_25_juin_2024`.
En l'occurence, aucune de ces propositions ne convient, car il est préférable de choisir un nom unique, informatif et court. 
Dans la fenêtre supérieure droite de RStudio, vous pouvez voir les noms de tous les objets actuellement chargés dans R. 

Lorsque vous importez vos données dans R, elles deviennent très probablement un objet appelé data frame. 
Un data frame est comme un tableau ou une feuille de calcul - il comporte des lignes et des colonnes avec les différentes variables 
et observations que vous avez chargées. Mais nous y reviendrons plus tard !

Une étape très importante consiste à vérifier que vos données ont été importées sans erreur. 
Une bonne pratique consiste à toujours exécuter le code qui suit (inscrit dans le script ou entré directement dans la console)
et à vérifier la sortie dans la console - voyez-vous des valeurs manquantes, les nombres et les noms ont-ils un sens ? 
Si vous passez directement à l'analyse, vous risquez de découvrir plus tard que R n'a pas lu vos données correctement 
et de devoir les refaire, ou pire, d'analyser des données erronées sans vous en rendre compte. 
Pour prévisualiser plus que les quelques premières lignes, vous pouvez également cliquer sur l'objet dans votre panneau Environnement, 
et il s'affichera sous la forme d'une feuille de calcul dans un nouvel onglet à côté de votre script ouvert. 
Les fichiers volumineux peuvent ne pas s'afficher entièrement ; n'oubliez donc pas qu'il peut manquer des lignes ou des colonnes.

```{r, eval=FALSE}
head(my_data)                # Affiche les premières lignes
tail(my_data)                # Affiche les dernières lignes
str(my_data)                 # Indique si les variables sont continues, entières, catégorielles ou des caractères.
```

`str(object.name)` est une excellente commande qui montre la structure de vos données. 
Très souvent, les analyses en R se déroulent mal parce que R décide qu'une variable est un certain type de données alors qu'elle ne l'est pas. 
Par exemple, vous pouvez avoir quatre groupes d'étude que vous appelez simplement « 1, 2, 3, 4 », 
et bien que vous sachiez qu'il devrait s'agir d'une variable de regroupement catégorique (c'est-à-dire un facteur), 
R peut décider que cette colonne contient des données numériques (nombres) ou entières (nombres entiers). 
Si vos groupes d'étude s'appellent « un, deux, trois, quatre », R peut décider qu'il s'agit d'une variable de caractère (mots ou chaînes de mots), 
ce qui ne vous mènera pas loin si vous voulez comparer les moyennes entre les groupes. 
Conclusion : vérifiez toujours la structure de vos données !

> Une bonne analyse de données commencent TOUJOURS par regarder ses données dans le détail. C'est à travers ces détails qu'émerge l'analyse pertinente et rigoureuse.

Lorsque vous souhaitez accéder à une seule colonne d'une base de données, 
vous devez ajouter le nom de la variable au nom de l'objet à l'aide d'un signe `$`. 
Cette syntaxe vous permet de voir, de modifier et/ou de réaffecter cette variable.

```{r, eval=FALSE}
head(my_data$var1)     # Affiche uniquement les premières lignes de cette colonne
class(my_data$var1)    # Indique le type de variable à laquelle nous avons affaire : imaginons que c'est un caractère, mais nous voulons que ce soit un facteur.

my_data$var1 <- as.factor(my_data$var1)     # Qu'est-ce qu'on fait ici ?!
```

Dans cette dernière ligne de code, la fonction `as.factor()` transforme les valeurs que vous avez introduites en un facteur 
(ici, nous avons spécifié que nous voulions transformer les valeurs de caractères dans la colonne `var1` de l'objet `my_data`). 
Toutefois, si vous n'exécutez que le bout de code situé à droite de la flèche, il fonctionnera une seule fois, 
mais ne modifiera pas les données stockées dans l'objet. 
En assignant avec la flèche la sortie de la fonction à la variable, l'original `my_data$var1` est en fait écrasé : 
la transformation est stockée dans l'objet. 
Essayez à nouveau d'exécuter class(my_data$var1) pour vérifier que la transformation a bien été réalisée.

```{r, eval=FALSE}
# More exploration
dim(my_data)                 # Affiche le nombre de lignes et de colonnes
summary(my_data)             # Vous donne un résumé des données
summary(my_data$var1)        # Vous donne un résumé de cette variable particulière (colonne) dans votre ensemble de données.
```

## Glossaire

Pour récapituler, voici quelques termes importants vu en abordant les notions de base :

- **argument** : un élément d'une fonction, essentiel ou facultatif, qui informe ou modifie le fonctionnement de la fonction. 
Par exemple, il peut s'agir du chemin d'accès à un fichier à partir duquel la fonction doit importer ou enregistrer : 
`file = \"chemin-fichier"`. Il peut modifier les couleurs d'un graphique : `col = \"blue\"`. 
Vous pouvez toujours savoir quels arguments sont pris par une fonction en tapant `?nom-de-la-fonction` dans la ligne de commande.
- **classe** : le type de données contenues dans une variable : généralement caractère (texte/mots), numérique (nombres), entier (nombres entiers) 
ou facteur (regroupement de valeurs, utile lorsque vous avez plusieurs observations pour des sites ou des traitements dans vos données).
- **commande** : morceau de code qui exécute une action et qui contient généralement une ou plusieurs fonctions. 
Vous exécutez une commande en appuyant sur « Exécuter » / « Run » ou en utilisant un raccourci clavier tel que `Cmd+Entrée`, 
`Ctrl+Entrée` ou `Ctrl+R`.
- **commentaire** : un bout de texte dans un script qui commence par un hashtag # et qui n'est pas lu comme une commande. 
Les commentaires rendent votre code lisible pour d'autres personnes (et pour vous même lorsque vous reprenez un code longue date) : 
utilisez-les pour créer des sections dans votre script et pour annoter chaque étape de votre analyse.
- **console** : la fenêtre dans laquelle vous pouvez taper du code directement dans la ligne de commande (`2+2` suivi de `Enter` renvoie `4`), 
et où les sorties des commandes que vous exécutez s'affichent.
- **data frame** : un type d'objet R composé de nombreuses lignes et colonnes ; pensez à une feuille de calcul Excel. 
En général, les colonnes représentent différentes variables (par exemple, le diamètre, la heuteur, l'essence...), 
et les lignes sont des observations de ces variables.
- **fichier csv** : un type de fichier couramment utilisé pour importer des données dans R, 
où les valeurs de différentes variables sont comprimées ensemble (une chaîne ou une ligne de valeurs par ligne) 
et séparées uniquement par des virgules (indiquant les colonnes) (ou des points virgules, des tabulations... 
à définir et préciser lors de l'importation et l'exportation des données). R peut également accepter les fichiers Excel (.xlsx), 
mais nous ne le recommandons pas car les erreurs de formatage sont plus difficiles à éviter.
- **fonction** : code qui effectue une action, et ce qui vous permet de faire ce que vous soulez dans R. 
Généralement, il prend une entrée, lui fait quelque chose, et renvoie une sortie (un objet, un résultat de test, un fichier, un tracé). 
Il existe des fonctions permettant d'importer, de convertir et de manipuler des données, d'effectuer des calculs spécifiques 
(pouvez-vous deviner ce que `min(10,15,5)` et `max(10,15,5)` renvoient ?), de créer des graphiques, etc.
- **objet** : les éléments constitutifs de R. Si R était une langue parlée, les fonctions seraient des verbes (actions) 
et les objets seraient des noms (les sujets ou, bien, les objets de ces actions !). 
Les objets sont appelés en tapant leur nom sans les guillemets. 
Les objets stockent des données et peuvent prendre différentes formes. 
Les objets les plus courants sont les dataframe et les vecteurs, mais il en existe beaucoup d'autres, tels que les listes et les matrices.
- **package** : un ensemble de fonctions qui fournissent des fonctionnalités à R. 
De nombreux packages sont fournis automatiquement avec R, d'autres peuvent être téléchargés pour des besoins spécifiques.
- **script** : Semblable à un éditeur de texte, c'est l'endroit où vous écrivez et sauvegardez votre code pour référence ultérieure. 
Il contient un mélange de code et de commentaires et est enregistré sous la forme d'un simple fichier texte 
que vous pouvez facilement partager afin que tout le monde puisse reproduire votre travail.
- **vecteur** : un type d'objet R à une dimension : il stocke une ligne de valeurs qui peuvent être des caractères, des nombres, etc.
- **répertoire de travail / working directory** : le dossier de votre ordinateur lié à votre session R en cours, 
dans lequel vous importez des données et enregistrez des fichiers. 
Vous le définissez au début de votre session avec la fonction `setwd()`.
- **espace de travail / workspace** : il s'agit de votre environnement de travail virtuel, 
qui contient toutes les fonctions des packages que vous avez chargés, les données que vous avez importées, les objets que vous avez créés, etc. 
Il est généralement préférable de commencer une session de travail avec un espace de travail clair.

## Sources

[Coding Club, Getting started with R and RStudio. Consulté en septembre 2024.](https://ourcodingclub.github.io/tutorials/intro-to-r/)
[Coding Club, Useful links. Consulté en septembre 2024.](https://ourcodingclub.github.io/links.html)

***
