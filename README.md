PROJET SUDOMIPS								
===============

### Yassine Hamoudi

Consulter aussi les fichiers joints : 				
 - Rapport.pdf : rapport du projet						 
 - Programme.s : programme MIPS de resolution	     	 
 - TEST : plusieurs grilles de test						 



Introduction
-----------------------------------------------------

Le projet SudoMips consiste a realiser un programme MIPS de resolution de grilles de Sudoku de taille 9x9. Le programme joint effectue cette tache. Le rapport apporte differentes precisions quant a son fonctionnement. Quelques points sont rappeles ici.


Compilation et execution du programme
-----------------------------------------------------

Le programme joint (fichier "Programme.s" ) peut etre charge a l'interieur du logiciel QtSpim. Cependant, pour ameliorer grandement sa rapidite d'execution, il est recommande de l'executer sous Linux en entrant dans le terminal la commande suivante :
		spim -file ./Programme.s


Utilisation du programme
-----------------------------------------------------
								
L'utilisateur du programme doit tout d'abord choisir une strategie de resolution a adopter.  Deux choix lui sont proposes : la strategie MIN ou la strategie MAX. Le fonctionnement de ces strategies est detaille dans le rapport joint.

Il faut ensuite initialiser la grille de depart. Celle-ci peut etre remplie depuis le terminal, ou inscrite directement dans le fichier "Programme.s".

Le programme verifie que la grille de depart ne contient pas deja des conflits, puis execute l'algorithme de resolution. Si une solution existe, elle est affichee, sinon l'utilisateur est informe de l'absence de solutions.


Utilisation du fichier TEST
-----------------------------------------------------

Le fichier "TEST" contient plusieurs grilles de Sudoku.

Pour essayer une de ces grilles, il suffit de la copier dans le fichier "Programme.s", a la place de la grille presente en debut de fichier.
