*Auteur : Valentin Mathieu - Dernière mise à jour 02 Septembre 2024*

***

# Dépannage et comment trouver de l'aide - Comment éviter les erreurs courantes dans l'analyse de données avec R

<!-- :240903:gf:r:enseignement: -->

La programmation s'accompagne d'une courbe d'apprentissage et vous rencontrerez sans doute de nombreux messages d'erreur lorsque vous vous familiariserez avec le fonctionnement de R. 
Mais n'ayez crainte ! Aujourd'hui, nous allons aborder certaines des erreurs de codage les plus courantes et vous aider à les éviter. 
Vous avez peut-être déjà vu certains de ces messages d'erreur, mais après avoir suivi ce tutoriel, on peut espérer qu'ils n'apparaîtront plus trop souvent sur vos écrans RStudio.

## Apprendre à détecter les erreurs dans R

Outre l'enregistrement de votre code, les scripts sont également utiles pour détecter les erreurs de codage simples avant même que vous n'exécutiez le code. 
Si RStudio détecte un caractère manquant, une commande qui n'a pas de sens en raison de fautes d'orthographe ou autres, un petit x rouge apparaît à côté de la ligne de code. 
C'est toujours une bonne idée de rechercher les x dans votre code avant de l'exécuter et c'est très pratique car vous savez exactement sur quelle ligne vous avez fait une erreur. 
L'autre façon dont R signale les erreurs est par le biais de messages dans la console, qui apparaissent après l'exécution d'un code qui n'est pas tout à fait correct. 
Bien que les messages d'erreur aient l'air effrayants (la police rouge et des mots comme « fatal » leur donnent une mauvaise réputation), ils constituent en fait la deuxième meilleure option par rapport à l'absence totale d'erreurs : R a identifié un problème et, à partir du message, vous pouvez comprendre de quoi il s'agit et le résoudre !

![](images/xandm.png)

## Se familiariser avec les erreurs courantes et les solutions

Voici une liste des erreurs que souvent comises.

- **Votre version de R ou de RStudio est trop ancienne (ou trop récente)**. 
Si vous n'avez pas mis à jour R ou RStudio depuis un certain temps, il se peut que vous ne puissiez pas utiliser certains des nouveaux packages qui sortent - lorsque vous essayez d'installer le package, vous obtenez un message d'erreur disant que le package n'est pas compatible avec votre version de RStudio. 
Ce problème est rapidement résolu par une visite sur le site web de [RStudio](https://www.rstudio.com/products/rstudio/) ou sur le [site web de R](https://cran.r-project.org/), où vous pouvez obtenir la version la plus récente. 
En revanche, lorsque vous obtenez la version la plus récente de RStudio, les packages qui n'ont pas été mis à jour récemment peuvent ne pas fonctionner, ou votre ancien code peut se casser. 
Cela se produit moins souvent et, en général, le code évolue constamment et s'améliore de plus en plus, il est donc bon de se tenir au courant des dernières versions à la fois de RStudio et des packages R.

- **Erreurs de syntaxe**. Les erreurs les plus faciles à commettre ! 
Vous avez oublié une virgule, ouvert une parenthèse sans la fermer, ajouté un caractère supplémentaire par erreur ou quelque chose d'autre que R ne comprend pas. 
Ces erreurs sont généralement détectées par R et vous recevrez des messages d'erreur vous rappelant de relire votre code et de le corriger. 
Si vous n'arrivez pas à trouver la bonne façon de coder ce dont vous avez besoin, il existe de nombreux endroits où vous pouvez [trouver de l'aide](https://ourcodingclub.github.io/tutorials/troubleshooting/#help).
Le respect d'[une étiquette de codage](R-good-practices.md) peut vous aider à réduire ces erreurs au minimum.

- **Vous essayez d'utiliser une certaine fonction et R ne la reconnaît pas**. Tout d'abord, il convient de vérifier si vous avez installé et chargé le package d'où provient la fonction. 
L'exécution du code `?nom-fonction`, par exemple `?filter`, affichera un écran d'aide contenant des informations sur l'utilisation de la fonction, ainsi que sur le package d'où elle provient.
Si vous avez chargé plusieurs packages similaires dans votre bibliothèque, ils peuvent contenir différentes fonctions portant le même nom et votre code peut s'interrompre si R ne sait pas laquelle utiliser - l'exécution de `package::function`, par exemple `dplyr::filter` renverra des informations sur la fonction dans la console. Notez que R essaiera d'ajouter `()` à la fin de `dplyr::filter`. Supprimez-les et exécutez le code.
Si vous vous documentez sur R en ligne, ou si vous copiez et modifiez du code, il se peut que vous utilisiez une fonction d'un nouveau package sans le savoir. 
Si elle ne vous semble pas familière, la recherche de son nom sur Google avec « r package » peut révéler son origine. 
Parfois, les packages dépendent d'autres packages pour fonctionner. 
Souvent, ceux-ci sont installés automatiquement lorsque vous installez le package, mais il arrive que vous receviez un message d'erreur vous demandant d'installer un autre package, ce qui est facilement résolu par `install.packages("newpackage")`.

- **Breakdown et debugging des fonctions**. Si vous exécutez des fonctions que vous avez créées vous-même ou des boucles for, il se peut que vous deviez utiliser le navigateur de debugging de R. 
Vous trouverez de l'aide sur la page d'aide au [debugging de RStudio](https://support.rstudio.com/hc/en-us/articles/205612627-Debugging-with-RStudio). 

- 