PROJET SUDOMIPS
===============

### Yassine Hamoudi

Consulter aussi les fichiers joints :
 - Rapport.pdf : rapport du projet	
 - Programme.s : programme MIPS de résolution 
 - TEST : plusieurs grilles de test



Introduction
-----------------------------------------------------

Le projet SudoMips consiste à réaliser un programme MIPS de résolution de grilles de Sudoku de taille 9x9. Le programme joint effectue cette tâche. Le rapport apporte différentes précisions quant à son fonctionnement. Quelques points sont rappelés ici.


Compilation et execution du programme
-----------------------------------------------------

Le programme joint (fichier "Programme.s" ) peut être chargé à l'interieur du logiciel QtSpim. Cependant, pour améliorer grandement sa rapidité d'exécution, il est recommandé de l'exécuter sous Linux en entrant dans le terminal la commande suivante :
		spim -file ./Programme.s


Utilisation du programme
-----------------------------------------------------
								
L'utilisateur du programme doit tout d'abord choisir une stratégie de résolution à adopter.  Deux choix lui sont proposés : la stratégie MIN ou la stratégie MAX. Le fonctionnement de ces stratégies est détaillé dans le rapport joint.

Il faut ensuite initialiser la grille de départ. Celle-ci peut être remplie depuis le terminal, ou inscrite directement dans le fichier "Programme.s".

Le programme vérifie que la grille de départ ne contient pas déjà des conflits, puis exécute l'algorithme de résolution. Si une solution existe, elle est affichée, sinon l'utilisateur est informé de l'absence de solutions.


Utilisation du fichier TEST
-----------------------------------------------------

Le fichier "TEST" contient plusieurs grilles de Sudoku.

Pour essayer une de ces grilles, il suffit de la copier dans le fichier "Programme.s", à la place de la grille présente en début de fichier.
