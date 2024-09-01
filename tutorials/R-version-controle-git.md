*Auteur : Valentin Mathieu - Dernière mise à jour 02 Septembre 2024*

***

# Introduction à GitHub pour le contrôle de version - Garder une trace de votre code et de ses nombreuses versions

<!-- :240903:gf:r:enseignement: -->

## Se familiariser avec le contrôle de version, Git et GitHub

### Qu'est-ce que le contrôle de version ?

Le contrôle de version vous permet de garder une trace de votre travail et vous aide à explorer facilement les modifications que vous avez apportées, qu'il s'agisse de données, de scripts de codage, de notes, etc. Vous effectuez probablement déjà un certain type de contrôle de version, si vous enregistrez plusieurs fichiers, tels que `Dissertation_script_25Feb.R`, `Dissertation_script_26Feb.R`, etc. Cette approche vous laissera avec des dizaines ou des centaines de fichiers similaires, ce qui rendra difficile la comparaison directe des différentes versions, et n'est pas facile à partager entre collaborateurs. Avec un logiciel de contrôle de version tel que [Git](https://git-scm.com/), le contrôle de version est beaucoup plus simple et facile à mettre en œuvre. L'utilisation d'une plateforme en ligne comme [Github](https://github.com/) pour stocker vos fichiers signifie que vous disposez d'une sauvegarde en ligne de votre travail, ce qui est bénéfique à la fois pour vous et pour vos collaborateurs.

Git utilise la ligne de commande pour effectuer des actions plus avancées et je vous encourage à consulter les [ressources supplémentaires que ajoutées à la fin du tutoriel du Coding Club sur le sujet](https://ourcodingclub.github.io/tutorials/git/#github4), afin d'être plus à l'aise avec Git. En attendant, nous allons voit ici une introduction à la synchronisation de RStudio et de Github, afin que vous puissiez commencer à utiliser le contrôle de version en quelques minutes.

### Quels sont les avantages de l'utilisation du contrôle de version ?

Le fait de disposer d'un dépôt GitHub facilite le suivi des projets collaboratifs et personnels - tous les fichiers nécessaires à certaines analyses peuvent être conservés ensemble et les personnes peuvent ajouter leur code, leurs graphiques, etc. au fur et à mesure que les projets se développent. Chaque fichier sur GitHub a un historique, ce qui permet d'explorer facilement les modifications qui y ont été apportées à différents moments. Vous pouvez examiner le code d'autres personnes, ajouter des commentaires à certaines lignes ou à l'ensemble du document, et suggérer des modifications. Pour les projets collaboratifs, GitHub vous permet d'assigner des tâches à différents utilisateurs, ce qui permet de savoir qui est responsable de quelle partie de l'analyse. Vous pouvez également demander à certains utilisateurs de réviser votre code. Pour les projets personnels, le contrôle de version vous permet de garder une trace de votre travail et de naviguer facilement parmi les nombreuses versions des fichiers que vous créez, tout en conservant une sauvegarde en ligne.

### Pour commencer

Veuillez vous enregistrer sur le [site Github](https://github.com/) et créer un compte.

Sur votre ordinateur, vous devez d'abord installer Git. La procédure dépend de votre système d'exploitation : veuillez suivre les instructions ci-dessous.

1. Si vous utilisez une distribution **Linux**, vous pouvez généralement installer Git en lançant la commande suivante dans le terminal (si cela ne fonctionne pas, consultez les instructions d'installation de Git pour votre distribution.) :
```
sudo apt-get install git
```

2. Si vous êtes sur une machine personnelle **Windows**, téléchargez et installez [Git](https://git-scm.com/downloads) pour votre système d'exploitation.

3. Si vous êtes sur une machine **Mac** personnelle, installez Git via [Homebrew](https://brew.sh), qui est un gestionnaire de packages pour les programmes en ligne de commande sur Mac. Tout d'abord, ouvrez un terminal, qui se trouve à `~/Application/Utilities/Terminal.app`. Ensuite, copiez et collez cette ligne dans le terminal et appuyez sur « Entrée » :

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Entrez maintenant ce qui suit pour installer Git :

```
brew install git
```

Suivez les instructions dans la fenêtre du terminal, vous devrez peut-être entrer le mot de passe de votre Mac ou accepter les questions en tapant oui.

Les fichiers que vous mettez sur GitHub seront publics (c'est-à-dire que tout le monde peut les voir et suggérer des modifications, mais seules les personnes ayant accès au dépôt peuvent directement modifier et ajouter/supprimer des fichiers). Vous pouvez également avoir des dépôts privés sur GitHub, ce qui signifie que vous seul pouvez voir les fichiers. GitHub propose désormais des [dépôts privés gratuits en standard](https://blog.github.com/2019-01-07-new-year-new-github/), avec un maximum de trois collaborateurs par dépôt. Ils offrent également un package d'éducation gratuit, avec un accès aux logiciels et d'autres avantages, vous pouvez en faire la demande en utilisant [ce lien](https://education.github.com/discount_requests/new).

## Comment fonctionne le contrôle des versions ?

### Qu'est-ce qu'un dépôt ?

Vous pouvez considérer un dépôt (ou repo) comme un « dossier principal ». Tout ce qui est associé à un projet spécifique doit être conservé dans un repo pour ce projet. Les dépôts peuvent contenir des dossiers ou simplement des fichiers séparés.

Vous aurez une copie locale (sur votre ordinateur) et une copie en ligne (sur GitHub) de tous les fichiers du dépôt.

### Le flux de travail

Le flux de travail de GitHub peut être résumé par le mantra « commit-pull-push ».

1. Commit
Une fois que vous avez enregistré vos fichiers, vous devez les commit - cela signifie que les modifications que vous avez apportées aux fichiers de votre dépôt seront enregistrées en tant que version du dépôt, et que vos modifications sont maintenant prêtes à être publiées sur GitHub (la copie en ligne du dépôt).
2. Pull
Avant d'envoyer vos modifications sur Github, vous devez les extraire, c'est-à-dire vous assurer que vous êtes parfaitement au courant de la dernière version de la version en ligne des fichiers - d'autres personnes ont pu travailler dessus même si vous ne l'avez pas fait. Vous devez toujours extraire les fichiers avant de commencer à les éditer et avant de les push.
3. Push
Une fois que vous êtes à jour, vous pouvez transférer vos modifications - à ce moment-là, votre copie locale et la copie en ligne des fichiers seront identiques.

Chaque fichier sur GitHub a un historique, donc au lieu d'avoir plusieurs fichiers comme `Dissertation_1er_Mai.R`, `Dissertation_2e_Mai.R`, vous pouvez en avoir un seul et en explorant son historique, vous pouvez voir à quoi il ressemblait à différents moments dans le temps.

Par exemple, voici l'historique d'un fichier markdown présentant les bases de R et utilisé pour ce cours, tel qu'il est affiché sur Github.

![](images/history.png)

## Créez votre propre dépôt/repo et votre propre structure de dossier de projet

Pour créer un dépôt/repo, allez dans `Dépôts/Nouveau dépôt` / `Repositories/New` - choisissez un nom concis et informatif, sans espaces ni caractères bizarres. Il peut s'agir de votre dépôt principal qui contient les recherches passées et en cours, les données, les scripts, les manuscrits. Plus tard, vous voudrez peut-être avoir plus de dépôts - par exemple un dépôt associé à un projet particulier que vous voulez rendre public ou un projet pour lequel vous cherchez activement à obtenir des commentaires d'un public plus large. Pour l'instant, nous allons nous concentrer sur l'organisation et l'utilisation de votre dépôt principal, qui contient les fichiers de tout votre travail. Avec un compte GitHub gratuit, vous pouvez utiliser des dépôts publics ou privés.

![](images/new_repo.png)

Créons un nouveau dépôt privé. Vous pouvez l'appeler comme vous le souhaitez si le nom est disponible.

![](images/create-repo.png)

**Cliquez sur `Initialiser le dépôt avec un fichier README.md` / `Add a README file`**. Il est courant que chaque dépôt/repo ait un fichier `README.md`, qui contient des informations sur le projet, l'objectif du dépôt, ainsi que des commentaires sur les licences et les sources de données. Github comprend plusieurs formats de texte, dont `.txt` et `.md`. `.md` signifie un fichier écrit en Markdown. Vous avez peut-être déjà utilisé Markdown dans RStudio pour créer des rapports bien organisés de votre code et de ses résultats (vous pouvez également consulter le [tutoriel Markdown du Coding Club](https://ourcodingclub.github.io/tutorials/rmarkdown/)). Vous pouvez également utiliser Markdown pour écrire des fichiers de texte brut, par exemple le fichier que vous êtes en train de lire a été écrit en Markdown.

**Nous allons également créer un fichier `.gitignore`**. Ce fichier permet à Git de savoir quels types de fichiers ne doivent pas être inclus dans le dépôt. Nous verrons ce fichier dans un instant. Cochez la case, puis recherchez R dans le modèle déroulant (ou tout autre langage de programmation que vous utiliserez pour le projet).

Une fois que vous êtes prêt, cliquez sur **Create repository**.

![](images/param-new-repo.png)

Voici à quoi devrait ressembler le référentiel :

![](images/my-first-repo-look.png)

Vous pouvez éditer directement votre fichier `README.md` sur Github en cliquant sur le fichier et en sélectionnant `Editer ce fichier`/ `Edit this file`.

![](images/edit-file.png)

### Exercice 1 : Écrire un fichier `README.md`informatif

Vous pouvez maintenant écrire le fichier `README.md` de votre dépôt. Pour faire des titres et des sous-titres, mettez des hashtags avant une ligne de texte - plus il y a de hashtags, plus le titre apparaîtra petit. Vous pouvez créer des listes en utilisant `-`, `+`, et les nombres `1, 2, 3, etc`. **Lorsque vous travaillez sur un projet partagé, discutez avec vos collaborateurs des éléments que vous souhaitez inclure** :

```
- Your name

- Project title

- Links to website & social media

- Contact details
```

Une fois que vous avez rédigé votre fichier `README.md`, allez jusqu'au bas de la page. Vous pouvez maintenant **commit** le fichier au dépôt. Pour ce faire, spécifiez un **message de commit** qui décrit brièvement les modifications. Les **messages de commit** doivent être concis, mais descriptifs. Sélectionnez **Commit directly to the `main` branch**, puis cliquez sur **Commit changes**.

![](images/comit-changes.png)

### Exercice 2 : Editer le fichier `.gitignore`

Les dépôts ont souvent un fichier appelé `.gitignore` et nous allons en créer un prochainement. Dans ce fichier, vous spécifiez les fichiers que vous voulez que Git ignore lorsque les utilisateurs font des changements et ajoutent des fichiers. Les exemples incluent les fichiers Word, Excel et Powerpoint temporaires, les fichiers `.Rproj`, les fichiers `.Rhist`, etc. Certains fichiers ne doivent se trouver que dans votre dépôt local (c'est-à-dire sur votre ordinateur), mais pas en ligne, car ils peuvent être trop volumineux pour être stockés en ligne. C'est le cas notamment des données volumineuses.

Sélectionnez le fichier `.gitignore` et cliquez sur `Edit`. Comme vous le verrez, le modèle fourni par GitHub pour R inclut déjà de nombreux types de fichiers que l'on trouve habituellement dans les projets R et qui ne devraient pas être inclus dans les dépôts partagés. Vous pouvez ajouter d'autres fichiers en spécifiant chaque type de fichier sur une ligne séparée. **Faites défiler le document jusqu'en bas et collez les ajouts suivants, sans écraser le reste**. Les commentaires dans le fichier sont désignés par le signe `#`. Ensuite, livrez le fichier à la branche principale.

```
# Prevent users to commit their own .RProj
*.Rproj

# Temporary files
*~
~$*.doc*
~$*.xls*
*.xlk
~$*.ppt*

# Prevent mac users to commit .DS_Store files
*.DS_Store

# Prevent users to commit the README files created by RStudio
*README.html
*README_cache/
#*README_files/
```

### Exercice 3 : Créer des dossiers

Pensez aux différents dossiers que vous pourriez vouloir inclure dans votre dépôt. Si vous travaillez sur un dépôt partagé, discutez-en avec vos collaborateurs. Pour le dépôt d'un groupe de laboratoire, voici quelques exemples : manuscrits, données, figures, scripts, `scripts/utilisateurs/dossier_personnel_votre_nom`. Pour créer un nouveau dossier, cliquez sur `Create new file` et ajoutez le nom de votre nouveau dossier, par exemple `manuscripts/` avant le nom du fichier, dans ce cas un fichier `README.md` rapide. Lorsque vous créez des dossiers dans votre repo via le site web de GitHub, vous devez toujours y associer au moins un fichier, vous ne pouvez pas simplement créer un dossier vide. Vous pouvez ensuite écrire et livrer le fichier.

![](images/new-folder.png)

### L'étiquette GitHub

Si vous partagez le dépôt avec des collaborateurs et même pour votre propre bénéfice, c'est une bonne idée de définir quelques règles sur la façon d'utiliser le dépôt avant de commencer à y travailler - par exemple, quelle étiquette GitHub et de codage les gens doivent-ils suivre ? Y a-t-il une structure de dossier préférée, un système de dénomination des fichiers ?

Nous pouvons créer un nouveau fichier `github-etiquette.md` qui décrit les règles que les personnes ayant accès à votre dépôt doivent suivre.

### Exercice 4 : écrire un fichier `github-etiquette.md`

Allez dans le dépôt principal, cliquez sur `Créer un nouveau fichier` et ajoutez `github-etiquette.md` comme nom de fichier. N'oubliez pas d'inclure l'extension .md - sinon GitHub ne saura pas quel est le format du fichier.

> Quelques règles de GitHub :
> 
> Les chemins d'accès aux fichiers doivent être courts et raisonnables.
> N'utilisez pas de caractères et d'espaces bizarres dans vos noms de fichiers, ils causent des problèmes en raison des différences entre les systèmes Mac et Windows.
> Pull toujours avant de commencer à travailler sur votre projet et avant de Push au cas où quelqu'un aurait fait du travail depuis la dernière fois que vous avez pull - vous ne voudriez pas que le travail de quelqu'un se perde ou que vous ayez à résoudre de nombreux conflits de codage.

## Synchroniser et interagir avec votre référentiel via RStudio

Le flux de travail « commit-pull-push » peut être intégré dans RStudio en utilisant des « Projets » et en activant le contrôle de version pour eux - nous le ferons bientôt dans le tutoriel.

Connectez-vous à votre compte Github et naviguez jusqu'au dépôt que vous avez créé plus tôt.

Cliquez sur Code et copiez le lien HTTPS.

![](images/clone-repo.png)

Ouvrez maintenant RStudio, cliquez sur `File/ New Project/ Version control/ Git` et collez le lien HTTPS du dépôt Github dans le champ `Repository URL :`. Sélectionnez un dossier sur votre ordinateur - c'est là que se trouvera la copie « locale » de votre dépôt (la copie en ligne se trouvant sur Github).

Une fois que vous aurez tenté le projet, il vous sera demandé de vous authentifier. **Vous ne devez le faire qu'une seule fois sur votre ordinateur**. Il existe plusieurs façons d'authentifier votre compte GitHub sur votre ordinateur et de le faire fonctionner avec RStudio. Voici deux approches recommandées :

### Créer un token d'accès personnel (toutes les plateformes)

La création d'un token d'accès personnel (PAT) est la méthode la plus sûre recommandée pour toutes les plateformes. Toutefois, si vous utilisez Windows (à partir de septembre 2021), vous pourrez peut-être vous authentifier en utilisant l'option rapide « Sign in via browser » (voire aprsè).

Vous pouvez créer un PAT en utilisant le site web de GitHub et spécifier les autorisations exactes qu'il donne à votre ordinateur lorsqu'il interagit avec GitHub dans le nuage. Nous allons créer un jeton qui permet d'accéder au dépôt et de le modifier.

#### Étape 1 : Créer un PAT sur le site web de GitHub

1. Sur le site web de GitHub, cliquez sur votre image de profil dans le coin supérieur droit et allez dans Paramètres.
2. Dans la barre latérale de gauche, cliquez sur `Developer settings`. Puis, toujours dans la barre latérale de gauche, cliquez sur `Jetons d'accès personnels`.
3. Cliquez sur `Générer un nouveau jeton`. Donnez un nom au jeton (quelque chose qui décrit l'usage que vous en ferez, par exemple « Jeton de machine locale »).
4. Sélectionnez une durée d'expiration. Vous pouvez choisir une durée d'expiration nulle afin de ne pas avoir à vous réauthentifier.
5. Ensuite, sélectionnez les permissions que vous accordez à ce jeton. Sélectionnez simplement le groupe « repo » en gras.
6. Cliquez sur `Generate token`. Veillez à copier le jeton et à le stocker en toute sécurité, car le site web ne vous le présentera plus. (En cas de problème, vous pouvez toujours en générer un nouveau).

Vous pouvez également suivre ce [guide avec des captures d'écran](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).

#### Étape 2 : S'authentifier (dans RStudio)

Sous Windows, une fois que vous interagissez avec un dépôt privé, vous devriez obtenir une invite ressemblant à ceci :

![](images/connect-github-rstudio.png)

Il suffit de coller le jeton dans le champ Jeton d'accès personnel et de continuer.

Sous Linux/macOS, vous devriez être invité à saisir votre nom d'utilisateur, puis votre mot de passe. Saisissez votre nom d'utilisateur GitHub, et sous mot de passe, saisissez votre PAT à la place.

Votre authentification devrait maintenant être réussie et vous pouvez interagir avec les dépôts GitHub directement à partir de RStudio.

### Se connecter via un navigateur internet

Sous Windows, lorsque vous essayez de cloner un dépôt privé depuis GitHub, vous devriez obtenir une invite comme celle-ci :

![](images/sign-in-browser.png)

Cliquez simplement sur « Se connecter via le navigateur » et autorisez votre appareil dans la fenêtre du navigateur qui s'affiche. L'authentification peut se faire automatiquement si vous êtes déjà connecté à GitHub dans votre navigateur.

Si vous n'obtenez pas une telle fenêtre, mais simplement une demande de saisie de votre nom d'utilisateur, suivez les instructions pour le jeton d'accès personnel ci-dessus.

Avant votre premier commit depuis votre ordinateur, vous devrez configurer votre nom d'utilisateur et votre email. C'est facile à faire, et vous n'avez besoin de le faire qu'une seule fois, après quoi vous pouvez faire un commit-pull-push à votre convenance !

Dans le coin supérieur droit de l'écran de RStudio (dans l'onglet Git), cliquez sur `More/Shell`.

NOTE : Si vous utilisez un PC Windows, l'option Shell devrait lancer Git Bash. Si ce n'est pas le cas, recherchez Git Bash sur votre ordinateur. Vous pouvez généralement le rechercher dans le menu Démarrer, ou faire un clic droit sur l'espace vide de n'importe quel dossier dans l'explorateur de fichiers et cliquer sur « Git Bash Here ».

#### Copy the following code:

```
git config --global user.email your_email@example.com
# Add the email with which you registered on GitHub and click Enter

git config --global user.name "Your GitHub Username"
# Add your GitHub username and click Enter
```

Si tout s'est bien passé, il n'y aura pas de message, vous pouvez fermer la fenêtre du shell et recommencer votre validation, cette fois-ci cela fonctionnera !

    Des problèmes ?

    Nous savons qu'il peut y avoir des problèmes avec les dernières mises à jour du logiciel Mac et avec l'installation de git et sa liaison avec RStudio. Les solutions semblent être très spécifiques à la version Mac que vous avez, donc si les étapes ci-dessus n'ont pas fonctionné, un bon point de départ est de googler « rstudio can't find git mac your version » et d'essayer les solutions suggérées.

Une fois que les fichiers ont fini d'être copiés (cela peut prendre un certain temps en fonction de la taille du repo que vous rejoignez), vous remarquerez que certaines choses ont changé dans votre session RStudio : il y a un onglet Git dans le coin supérieur droit de RStudio, et tous les fichiers qui se trouvent dans le repo sont maintenant sur votre ordinateur également.

Vous êtes maintenant prêt à apporter des modifications et à les documenter via Github ! **Notez que vous ne pouvez pas push des dossiers vides**.

Vous pouvez ouvrir certains des fichiers que vous avez mis en ligne plus tôt - par exemple, si vous cliquez sur votre fichier `README.md`, il s'ouvrira dans RStudio et vous pourrez y apporter des modifications. Ajoutez un peu de texte pour illustrer le fonctionnement du contrôle de version. Enregistrez le fichier au même endroit (c'est-à-dire dans votre repo).

![](images/first-diff.png)

Si vous cliquez sur l'onglet Git, vous verrez que votre fichier `README.md` y est listé. Cochez-le. Il y a maintenant un M - cela signifie que vous avez modifié le fichier. S'il y a un A, c'est un fichier ajouté, et un D est un fichier supprimé.

Si vous sélectionnez le fichier `README.md` et que vous cliquez sur `Diff`, vous verrez les modifications que vous avez apportées. Une fois le fichier sélectionné, il est `staged`, prêt à être transmis à Github.

Cliquez sur `Commit` et ajoutez votre message de `commit` - essayez d'être concis et informatif - qu'avez-vous fait ? Une fois que vous avez cliqué sur `Commit`, vous recevez un message indiquant les modifications que vous avez apportées.

![](images/first-commit.png)

Vous verrez un message indiquant que votre branche a maintenant un commit d'avance sur la branche `origin/main` - c'est la branche qui est sur Github - nous devons maintenant informer Github des changements que nous avons faits.

![](images/your-branch-ahead.png)

On ne le répétera jamais assez : il faut toujours pull avant de push. Pull signifie que vous récupérez la version la plus récente du dépôt Github sur votre branche locale - cette commande est particulièrement utile si plusieurs personnes travaillent sur le même dépôt - imaginez qu'il y ait un second script examinant le pH du sol le long de ce gradient d'altitude, et que votre collaborateur travaille dessus en même temps que vous - vous ne voudriez pas « écraser » leur travail et causer des problèmes. Dans ce cas, vous êtes le seul à travailler sur ces fichiers, mais il est toujours bon de prendre l'habitude de pull avant de push. Une fois que vous avez pull, vous verrez un message indiquant que vous êtes déjà à jour, vous pouvez maintenant push ! Cliquez sur Push, attendez que le chargement soit terminé et cliquez sur Close - c'est tout, vous avez réussi à pousser votre travail sur Github !

Retournez à votre dépôt sur Github, où vous pouvez maintenant voir tous vos fichiers mis à jour en ligne.

Cliquez sur votre fichier de script et ensuite sur `Historique` / `History` - c'est là que vous pouvez voir les différentes versions de votre script - évidemment, dans des situations réelles, vous ferez de nombreux changements au fur et à mesure que votre travail progresse - ici, nous n'en avons que deux. Grâce à Github et au contrôle de version, vous n'avez pas besoin de sauvegarder des centaines de fichiers presque identiques (par exemple `Dissertation_script_25Feb.R`, `Dissertation_script_26Feb.R`) - vous avez un seul fichier et en cliquant sur les différents commits, vous pouvez voir à quoi il ressemblait à différents moments.

**Vous êtes maintenant prêt à ajouter vos scripts, vos tracés, vos fichiers de données, etc. à votre nouveau répertoire de projet et à suivre le même flux de travail que celui décrit ci-dessus - mettre en scène vos fichiers, commit, pull, push.**

## Problèmes potentiels

Vous verrez parfois des messages d'erreur lorsque vous essaierez de faire un commit-pull-push. En général, le message d'erreur identifie le problème et le fichier auquel il est associé. Si le message est plus obscur, une recherche sur Google est un bon moyen de résoudre le problème. Voici quelques problèmes potentiels qui peuvent survenir :

### Conflits de code

Pendant que vous travailliez sur une certaine partie d'un script, quelqu'un d'autre travaillait également dessus. Lorsque vous effectuez un commit-pull-push, GitHub vous demande de choisir la version que vous souhaitez conserver. C'est ce qu'on appelle un conflit de code, et vous ne pouvez pas continuer tant que vous ne l'avez pas résolu. Vous verrez des flèches ressemblant à `>>>>>>>>>` autour des deux versions du code - supprimez la version du code que vous ne voulez pas garder, ainsi que les flèches, et votre conflit devrait disparaître.

### Push les mauvais fichiers

Si vous avez accidentellement poussé ce que vous n'aviez pas l'intention de pousser, supprimé beaucoup de choses (ou tout !) et push des dossiers vides, vous pouvez revenir sur votre livraison. Vous pouvez continuer à revenir en arrière jusqu'à ce que vous atteigniez le moment où tout allait bien. C'est une solution facile si vous êtes la seule personne à travailler dans le référentiel - sachez que si d'autres personnes ont participé au référentiel, revenir en arrière annulera également tout leur travail, car revenir en arrière se réfère au référentiel dans son ensemble, et pas seulement à votre propre travail.

L'utilisation de ces commandes « annuler » peut être décourageante, alors assurez-vous de lire les différentes commandes avant de tenter quoi que ce soit qui pourrait effacer le travail de façon permanente : [voici un début](https://www.atlassian.com/git/tutorials/undoing-changes/git-revert). C'est une bonne idée de sauvegarder régulièrement votre dépôt sur un disque dur externe, juste au cas où !

### Commits vérifiés

Lorsque vous parcourez l'historique de vos commits sur le site de GitHub, vous pouvez remarquer que les commits effectués via le site sont listés comme « vérifiés », alors que les commits poussés depuis votre ordinateur ne le sont pas. Ce n'est généralement pas un problème, mais dans les grands projets collaboratifs, vous pouvez vouloir vérifier vos commits faits localement - [voici un guide sur la façon de le faire](https://docs.github.com/en/github/authenticating-to-github/about-commit-signature-verification).

## Synchroniser et interagir avec votre dépôt via la ligne de commande

Traditionnellement, Git utilise la ligne de commande pour effectuer des actions sur les dépôts Git locaux. Dans ce tutoriel, nous avons ignoré la ligne de commande, mais elle est nécessaire si vous souhaitez avoir plus de contrôle sur Git. Il existe plusieurs excellents guides d'introduction au contrôle de version à l'aide de Git, par exemple le [guide Numeracy, Modelling and Data management du professeur Simon Mudd](http://simon-m-mudd.github.io/NMDM_book/#_version_control_with_git), le [guide The Software Carpentry](https://swcarpentry.github.io/git-novice/) et ce [guide issu de l'atelier Version Control de la British Ecological Society](https://github.com/BES2016Workshop/version-control). Pour des outils de ligne de commande plus génériques, consultez cet [aide-mémoire général](https://www.git-tower.com/blog/command-line-cheat-sheet) et [cet aide-mémoire pour les utilisateurs de Mac](https://github.com/0nn0/terminal-mac-cheatsheet). Le Coding Club a également créé un tableau et un diagramme de flux avec quelques commandes Git de base et la façon dont elles s'intègrent dans le flux de travail Git/Github. Les lignes orange se réfèrent au flux de travail principal, les lignes bleues décrivent des fonctions supplémentaires et les lignes vertes traitent des branches :

![](images/git_cli_nmdm.png)

![](images/table-git.png)

Vous trouverez ci-dessous un exercice rapide vous permettant de vous familiariser avec ces outils de ligne de commande. Il y a plusieurs façons d'interagir avec Git en utilisant le terminal :

1. Si vous êtes déjà dans RStudio sur une machine Mac ou Linux, vous pouvez ouvrir un terminal dans RStudio en allant à `Outils -> Terminal -> Nouveau terminal` dans le menu.
2. Si vous êtes sur une machine Mac ou Linux, vous pouvez simplement ouvrir un programme de terminal et lancer Git à partir de là. La plupart des machines Mac et Linux ont Git installé par défaut. Sur Mac, vous pouvez ouvrir un terminal en allant dans : `Applications/Utilities/Terminal.app`.
3. Si vous êtes sur une machine personnelle Windows, vous pouvez lancer Git en utilisant Git Bash, qui peut être installé lorsque vous avez installé Git. Vous devriez pouvoir le lancer à partir de `More -> Shell` dans RStudio. Si cela ne fonctionne pas, recherchez le programme dans votre menu Démarrer.

![](images/rstudio_new_terminal.png)

Une fois que vous avez ouvert un terminal en utilisant l'une des méthodes ci-dessus, commencez par créer un dossier appelé `git_test` quelque part sur votre système local, à l'aide de la commande `mkdir` (make directory) en tapant ce qui suit dans le terminal et en appuyant sur la touche « Entrée ». Par exemple, pour créer le répertoire dans le dossier Documents :

```
mkdir ~/Documents/git_test
```

Entrez ensuite dans ce dossier en utilisant `cd` (changer de répertoire) :

```
cd ~/Documents/git_test
```

Pour transformer le dossier en dépôt Git :

```
git init
```

Maintenant, le dossier a été transformé en dépôt Git, ce qui vous permet de suivre les modifications apportées aux fichiers. Maintenant, créons un fichier `README.md` à l'intérieur du dépôt et mettons-y du texte, en utilisant l'éditeur de texte avec lequel vous êtes à l'aise. Assurez-vous de placer ce fichier `README.md` dans le dossier du dépôt sur votre appareil afin qu'il puisse être trouvé !

Vous pouvez créer des fichiers texte vides à l'aide d'une simple commande dans l'interpréteur de commandes :

```
touch README.md
touch .gitignore
touch test.R
```

Maintenant, pour ajouter un fichier à suivre par le dépôt Git :

```
git add README.md
```

Pour vérifier quels sont les fichiers qui ont fait l'objet de modifications dans le cadre d'une mise en scène et d'une mise à jour :

```
git status
```

Le fichier README.md a été ajouté à la zone de transit, mais n'a pas encore été intégré à une version du dépôt/repo. Pour valider une version :

```
git commit -m "Your commit message here"
```

Actuellement, le dépôt Git se trouve uniquement sur notre ordinateur local. Les versions sont livrées, mais elles ne sont pas sauvegardées sur une version distante du dépôt sur Github. Allez sur Github et créez un dépôt appelé git_test, comme vous l'avez fait plus tôt dans l'atelier, mais cette fois-ci ne créez pas de README.md parce que nous venons juste d'en créer un sur l'ordinateur local. Maintenant, copiez le lien HTTPS pour ce dépôt. Dans le terminal, liez le dépôt Git local avec le dépôt distant en utilisant le code suivant, en remplaçant <HTTPS_LINK> par le lien que vous avez copié :

```
git remote add origin <HTTPS_LINK>
```

Ensuite, faites le premier push vers ce dépôt distant nouvellement lié :

```
git push -u origin main
```

Vous pouvez maintenant continuer à éditer des fichiers, à ajouter des modifications (`git add <FILE>`), à valider des modifications (`git commit`), à extraire (`git pull`) et à pousser (`git push`) des modifications, comme vous le faisiez en cliquant sur des boutons dans RStudio. N'hésitez pas à explorer certaines des commandes plus avancées présentées dans le tableau et l'organigramme ci-dessus. Vous pouvez également consulter un tutoriel sur la ligne de commande plus avancé rédigé par le professeur [Simon Mudd pour le guide Numeracy, Modelling and Data management](http://simon-m-mudd.github.io/NMDM_book/#_version_control_with_git).

***