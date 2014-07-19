###################################################################
###################################################################
##																 ##
##	PROJET SUDOMIPS											     ##
##																 ##
##  Yassine Hamoudi												 ##
##															     ##
## ------------------------------------------					 ##
##																 ##
## Fichier Programme.s										 	 ##
##															     ##
## ------------------------------------------					 ##
##																 ##
##	Consulter  aussi les fichiers joints : 						 ##
##		- README : informations sur l'utilisation du programme	 ##
##		- Rapport.pdf : rapport du projet						 ##
##		- TEST : plusieurs grilles de test						 ##
##																 ##
##																 ##
###################################################################
###################################################################

# Il est recommande de definir la largeur des tabulations sous gedit a 4 pour obtenir un affichage clair des fichiers.




.data

#####################################################################
#				      												#
#	// LA GRILLE //   												#
#     la grille initiale peut etre remplie ci-dessous, ou depuis	#
#     le terminal lors de l'execution du programme					#
#		(des grilles tests figurent dans le fichier TEST joint)		#
#				      												#
#####################################################################

grille : 
	.byte 5, 3, 0, 0, 7, 0, 0, 0, 0
	.byte 6, 0, 0, 1, 9, 5, 0, 0, 0
	.byte 0, 9, 8, 0, 0, 0, 0, 6, 0
	.byte 8, 0, 0, 0, 6, 0, 0, 0, 3
	.byte 4, 0, 0, 8, 0, 3, 0, 0, 1
	.byte 7, 0, 0, 0, 2, 0, 0, 0, 6
	.byte 0, 6, 0, 0, 0, 0, 2, 8, 0
	.byte 0, 0, 0, 4, 1, 9, 0, 0, 5
	.byte 0, 0, 0, 0, 8, 0, 0, 7, 9



	
##################################
#								 #
#	// CHAINES DE CARACTERES //	 #
#								 #
##################################

debut : 				.asciiz "-------------- \n|  SudoMips   | \n--------------\n"
demande_strategie :		.asciiz "\n Veuillez entrer la strategie a appliquer (0 : strategie MIN, 1 : strategie MAX) : \n \n"
demande_saisie : 		.asciiz "\n Veuillez entrer le mode de saisie de la grille initiale (0 : la grille a ete remplie dans le code source, 1 : la grille doit etre rentree manuellement) : \n \n"
demande_position_x : 	.asciiz "\n Saisissez la ligne du nombre a ajouter (1<=..<=9), entrez 0 pour mettre fin a la saisie de la grille initiale : \n \n"
demande_position_y :	.asciiz "\n Saisissez la colonne du nombre a ajouter (1<=..<=9) : \n \n"
demande_nombre : 		.asciiz "\n Saisissez le nombre a mettre dans cette case : \n \n"
espace : 				.asciiz " | "
line_normal : 			.asciiz "\n  |           |           |           |\n  | "
line_separate : 		.asciiz "\n  |-----------+-----------+-----------|\n  | "
line_end : 				.asciiz "\n  |-----------+-----------+-----------|\n"
point : 				.asciiz "."
string_debut :			.asciiz " \n Voici la grille initiale : \n \n"
string_fail : 			.asciiz " \n Aucune solution n'existe. \n"
string_success : 		.asciiz " \n Voici une solution a la grille : \n \n"
	
	


#################
#				#
#  // MAIN //	#
#				#
#################	
	
.text

main :

# Usage des registres de sauvegarde :
	# $s0 : 0  si strategie minimum, 10 si strategie maximum
	# $s1 : 10 si strategie minimum, 0 si strategie maximum
	# $s2 : 1  si strategie minimum, -1 si strategie maximum
	# $s6 : utilise lors du remplissage manuel de la grille par l'utilisateur, contient la position de la case en cours de remplissage
	# $s7 : utilise pour verifier que la grille de depart ne contient pas deja de conflits. Contient les positions successives testees.
	

	la $a0, debut		
	li $v0, 4
	syscall						# on affiche "SudoMips"
	
	jal remplir_user			# l'utilisateur donne ses options (strategie, mode de remplissage de la grille)
	
	la $a0, string_debut		
	li $v0, 4
	syscall						# on affiche "Voici la grille initiale :"
	jal affichage				# on affiche la grille de depart
	
	jal grille_valide			# on verifie que la grille initiale ne contient pas deja des conflits
	beq $v0, $0, return_fail	# si elle n'est pas fausse, on poursuit
	jal backtracking			# application de l'algo de backtracking
	beq $v0, $0, return_fail	# si $v0=0, l'algo n'a trouve aucune solution, sinon il a reussi a remplir la grille

return_success : 				# l'algo a trouve une solution
	la $a0, string_success
	li $v0, 4
	syscall						# on affiche : "Voici une solution a la grille :"

	jal affichage				# on affiche la grille remplie
	
	li $v0, 10				
	syscall						

return_fail : 					# il n'y a pas de solution
	la $a0, string_fail
	li $v0, 4
	syscall						# on affiche "Aucune solution n'existe."
	li $v0, 10				
	syscall




#################################################################
#				   												#
# // REMPLIR_USER //											#
#  permettre a l'utilisateur de remplir la grille initiale		#
#  et de choisir une strategie 			 						#
#				   												#
# Entree : 														#
#				   												#
# Sortie :	 													#
#		  														#
#################################################################

remplir_user :  
	sub $sp, $sp, 4
	sw $ra, 0($sp)								# on sauve l'adresse de retour sur la pile
	
remplir_user_strategie : 
	la $a0, demande_strategie					# demander quelle strategie appliquer
	li $v0, 4
	syscall							
	li $v0, 5
	syscall										# dans v0 : 0 si strat MIN, 1 si strat MAX
	
	move $s0, $v0								# dans s0 : strategie choisie (0 ou 1)
	mul $s0, $s0, 10							# dans s0 : 0 si MIN, 10 si MAX
	bne $s0, $0, remplir_user_strategie_max     # on remplie $s1 et $s0 selon la strategie choisie (cf conventions de remplissage au debut du main)

remplir_user_strategie_min : 					
	li $s1, 10
	li $s2, 1
	j remplir_user_saisie						# on passe au remplissage de la grille initiale
	
remplir_user_strategie_max : 
	li $s1, 0
	li $s2, -1
	
remplir_user_saisie : 
	la $a0, demande_saisie		# demander si l'utilisateur souhaite remplir manuellement la grille
	li $v0, 4
	syscall
	li $v0, 5
	syscall						# dans v0 : 0 si grille remplie directement dans le fichier, 1 si remplissage manuel depuis terminal
	
	move $a0, $v0				# dans a0, type de remplissage choisie (0 ou 1)
	
	jal init					# on appelle init, qui va mettre des 0 ou des 10 dans les cases vides (depend de la strategie et du mode de remplissage choisi)
	
	beq $a0, $0, remplir_user_end	# si l'user a choisi un remplissage directement dans le fichier, on a fini. Sinon, on poursuit avec le remplissage manuel
	
	jal affichage				# on affiche la grille totalement vide

remplir_user_case :					# remplissage manuel de la grille
	la $a0, demande_position_x 		# demander une position x
	li $v0, 4
	syscall 
	li $v0, 5
	syscall							# mettre position_x dans $v0
	
	move $s6, $v0					# mettre position_x dans $s6
	beq $s6, $0, remplir_user_end	# si c'est 0, on quitte
	sub $s6, 1						# decalage de 1 (on compte les lignes de 0 a 8)
	mul $s6, $s6, 9					# mettre dans s6 premiere case de la ligne s6
	sub $s6, 1						# decalage de 1 (on compte les colonnes de 0 a 8)
	
	la $a0, demande_position_y 	# demander une position y
	li $v0, 4
	syscall 
	li $v0, 5
	syscall						# mettre position_y dans $v0
	
	add $s6, $s6, $v0			# dans s6 : case choisie par l'user
	
	la $a0, demande_nombre 		# demander un nb
	li $v0, 4
	syscall 
	li $v0, 5
	syscall						# mettre nb dans $v0
	
	sb $v0, grille+0($s6)		# enregistrer le nb dans la grille
	
	jal affichage				# afficher la grille
	
	j remplir_user_case			# passer a la case suivante

remplir_user_end : 
	lw $ra, 0($sp)						# on recupere l'adresse de retour
	addi $sp, $sp, 4					# on depile le -1
	jr $ra
	


	
###################################################################################################
#				   																	 			  #
# // INIT //											   							 			  #
#  initialise la grille initiale : met des 0 ou des 10 								 			  #
#   si strategie MIN : 																  			  #
#		si remplissage manuel de la grille : mettre des 0 dans toutes les cases		 			  #
#		si remplissage directement dans le fichier : remplacer les 10 eventuels par des 0		  #
#   si strategie MAX :																  			  # 
#		si remplissage manuel de la grille : mettre des 10 dans toutes les cases				  #
#		si remplissage directement dans le fichier : remplacer les 0 eventuels par des 10		  #
#				   																	  			  #	
# Entree :																			  			  #		 					
#	$a0 : 0 si auto (ie depuis un fichier), 1 si manuel						 					  #
#				   																	 			  #
# Sortie :  																		 			  #
#																					 			  #
#		  																			 			  #
###################################################################################################

init : 
	li $t0, -1							# va contenir la position courante dans la grille
	beq $a0, $0, init_remplir_auto

init_remplir_manuel : 					# si l'utilisateur veut remplir manuellement
	addi $t0, $t0, 1					# on va a la case suivante
	beq $t0, 81, init_end				# si fin de grille, on sort
	sb $s0, grille+0($t0)				# sinon on met s0 (0 ou 10) dans la case
	j init_remplir_manuel
	
init_remplir_auto : 					# si l'utilisateur veut remplir automatiquement, permet d'uniformiser les 0 et 10 suivant la strat choisie
	addi $t0, $t0, 1					# on va a la case suivante
	beq $t0, 81, init_end				# on a fini
	lb $t1, grille+0($t0)
	bne $t1, $s1, init_remplir_auto		# si t1 = s1, on doit inverser son contenu
	sb $s0, grille+0($t0)
	j init_remplir_auto
		
init_end : 
	jr $ra
	
	


#########################################################
#				   										#
# // VERIFICATEUR //									#
#  verifie si un nb mis a une certaine position			#
#  ne contredit pas le reste de la grille				#
#				   										#
# Entree : 												#
#	$a0 : nb a tester									#
#	$a1 : position de la case a tester (0<=..<=80)		#
#				   										#
# Sortie : 												#
#	$v0 : 0 si non valide								#
#		  1 si valide									#
#########################################################

verificateur : 	
	li $t9, 9
	div $a1, $t9
	mflo $t0			# ligne contenant a1
	mfhi $t2			# colonne contenant a1 = premiere case de la colonne contenant a1
	
	mul $t1, $t0, 9	 	# premiere case de la ligne contenant a1

	addi $t3, $t1, 9 	# premiere case de la ligne en dessous de a1 (81 si on est en bout de grille)
	addi $t5, $t2, 81 	# premiere case située sous la colonne contenant a1 (81<=..<=89)
	
verificateur_ligne_valide : 
	beq $t1, $t3, verificateur_colonne_valide			# si on a fini la ligne, on teste la colonne
	beq $t1, $a1, verificateur_avancer_horizontalement 	# si on arrive sur la case a1, on l'evite

	lb $t4, grille + 0($t1)								# contenue de la case ou on est
	beq $t4, $a0, verificateur_fail						# a0 n'est pas compatible avec cette case

verificateur_avancer_horizontalement :					# la case actuelle est compatible avec a0, on avance
	addi $t1, $t1, 1
	j verificateur_ligne_valide

verificateur_colonne_valide : 
	beq $t2, $t5, verificateur_bloc_valide				# si on a fini la colonne, on teste le bloc
	beq $t2, $a1, verificateur_avancer_verticalement 	# si on arrive sur la case a1, on l'evite
	
	lb $t4, grille + 0($t2)								# contenue de la case
	beq $t4, $a0, verificateur_fail						# a1 n'est pas compatible avec cette case
	
verificateur_avancer_verticalement  : 					# la case actuelle est compatible avec a0, on avance
	addi $t2, $t2, 9
	j verificateur_colonne_valide

verificateur_bloc_valide :
	sub $t5, $t5, 81
	div $t6, $t0, 3
	mul $t6, $t6, 27	# premiere case de la ligne contenant la case en haut a gauche du bloc de a1
	div $t7, $t5, 3
	mul $t7, $t7, 3		# colonne contenant la case en haut a gauche du bloc contenant a1 (0, 3 ou 6)
	add $t6, $t6, $t7	# case en haut a gauche du bloc contenant a1
	
	addi $t7, $t6, 3								# fin de ligne
	addi $t8, $t6, 27								# fin de bloc
	
verificateur_bloc_valide_parcours :
	beq $t6, $t8, verificateur_success				# on a verifie tout le bloc
	beq $t6, $t7, verificateur_bloc_ligne_suivante	# on a verifie une ligne
	beq $t6, $a1, verificateur_bloc_case_suivante	# on passe a la case suivante
	
	lb $t4, grille + 0($t6)							# contenue de la case
	beq $t4, $a0, verificateur_fail					# a1 n'est pas compatible avec cette case, on echoue
	j verificateur_bloc_case_suivante				# a1 est compatible : on avance 
	
verificateur_bloc_ligne_suivante : 					# on passe a la ligne suivante du bloc
	addi $t6, $t6, 6								# debut de la ligne
	addi $t7, $t7, 9								# fin de la ligne
	j verificateur_bloc_valide_parcours

verificateur_bloc_case_suivante :					# on passe a la case suivante
	addi $t6, $t6, 1
	j verificateur_bloc_valide_parcours

verificateur_success : 
	li $v0, 1
	jr $ra
	
verificateur_fail : 
	li $v0, 0
	jr $ra




#########################################################
#				   										#
# // GRILLE_VALIDE //									#
#  test si la grille en entree est valide 				#
#				   										#
# Entree :	 											#
#				   										#
# Sortie :												#
#	$v0 : 0 si non valide, 1 sinon						#
#				   										#
#########################################################

grille_valide : 
	li $s7, -1				# cases successives de la grille
	li $v0, 1				# valeur de retour
	sub $sp, $sp, 4
	sw $ra, 0($sp)			# on sauve l'adresse de retour sur la pile	 

grille_valide_parcourir : 
	addi $s7, $s7, 1						# on va a la case suivante
	beq $s7, 81, grille_valide_exit			# on a parcouru toute la grille, on sort
	lb $a0, grille + 0($s7)					# contenue de la case ou on est
	beq $a0, $s0, grille_valide_parcourir	# 0 ou 10 dans la case actuelle, on la saute
	move $a1, $s7							# on met s7 dans a1 (en vu de l'appel de la fonction verificateur)
	jal verificateur						# on lance la verification
	beq $v0, $0, grille_valide_exit			# conflit dans la case actuelle, on quitte avec $v0=0
	j grille_valide_parcourir				# pas de conflit, on passe a la case suivante

grille_valide_exit :
	lw $ra, 0($sp)			# on recupere l'adresse de retour
	addi $sp, $sp, 4
	jr $ra



	
#############################################################################
#				   															#
# // BEST //																#
#  si strategie MIN : trouve le plus petit nb (stricement superieur a $a0)	#	 
#					  pouvant etre mis dans la case $a1						#
#  si strategie MAX : trouve le plus grand nb (stricement inferieur a $a0)	# 
#					  pouvant etre mis dans la case $a1						#  
#				   															#
# Entree :	 																#	
#	$a0 : plus petit, ou plus grand, nb non permis							#
#	$a1 : position de la case a remplir (0<=..<=80)							#
#				   															#
# Sortie : 																	#
#	$v0 : si aucune nb possible, contient $s0								#
#		  sinon, contient un nb 1<=..<=9 possible							#
#				   															#
#############################################################################

best :
	sub $sp, $sp, 4
	sw $ra, 0($sp)				# on sauve l'adresse de retour sur la pile	 
	move $v0, $s0				# on initialise $v0, au cas ou on jump directement a best_exit_fail
	
best_parcourir :
	add $a0, $a0, $s2				# on teste si le chiffre suivant, ou precedant, $a0 est possible
	beq $a0, $s1, best_exit_fail	# si on a teste tous les chiffres sans succes, on sort
	jal verificateur				# on lance la fonction de verification
	beq $v0, $0, best_parcourir		# le chiffre ne convient pas, on passe au suivant
	move $v0, $a0					# sinon a0 est valide, on le met dans v0
	
best_exit :
	lw $ra, 0($sp)			# on recupere l'adresse de retour
	addi $sp, $sp, 4
	jr $ra
	
best_exit_fail :
	move $v0, $s0			# on place s0 dans v0 (0 si strategie MIN, 10 si strategie MAX) 
	lw $ra, 0($sp)			# on recupere l'adresse de retour
	addi $sp, $sp, 4
	jr $ra



	
#########################################################
#				   										#
# // BACKTRACKING //									#
#  essayer de remplir la grille avec une strategie		#
#  de bactracking										#
#				   										#
# Entree : 												#
#				   										#
# Sortie : 												#
#	$v0 : 0 si aucune solution, 1 sinon					#
#		  												#
#########################################################

backtracking :
	li $a1, -1								# position courante dans la grille (0<=..<=80)
	
	sub $sp, $sp, 8
	sw $ra, 4($sp)							# on sauve l'adresse de retour sur la pile
	sw $a1, 0($sp)							# permet de detecter le fond de pile = -1
	
backtracking_parcourir :
	addi $a1, $a1, 1						# on passe a la case suivante
	beq $a1, 81, backtracking_success		# on a reussit a tout remplir, on renvoie success
	lb $a0, grille + 0($a1)					# contenue de la case numero $a1
	bne $a0, $s0, backtracking_parcourir	# on ne touche pas a la case si elle est imposee (ie contient 0 (strat MIN) ou 10 (strat MAX))

backtracking_remplissage :					# dans a1 : position de la case actuelle, dans a0 : plus petit nb non permis pour a1
	jal best								# on cherche un chiffre dans la case $a1, en accord avec la strategie choisie (si MIN : le nb choisie doit etre strictement superieur a a0, si MAX : strictement inferieur)
	sb $v0, grille + 0($a1)					# on met le chiffre obtenu dans la grille
	beq $v0, $s0, backtracking_go_back		# si c'est s0, c'est qu'aucun chiffre ne convient, il faut revenir en arriere
	sub $sp, $sp, 4							# sinon, on se rappelle que cette position peut etre modifiee
	sw $a1, 0($sp)							# on empile la position qu'on vient de remplir
	j backtracking_parcourir				# on passe a la case suivante
											
backtracking_go_back :
	lw $a1, 0($sp)							# on recupere la precedente case remplie
	beq $a1, -1, backtracking_fail			# on s'assure qu'on n'est pas en fond de pile
	addi $sp, $sp, 4						# on depile
	lb $a0, grille + 0($a1)					# contenue de la case numero $a1
	j backtracking_remplissage		 		# on esssaye de poursuivre le remplissage

backtracking_fail : 
	li $v0, 0				# argument de retour
	addi $sp, $sp, 4		# on enleve le -1 de la pile
	lw $ra, 0($sp)			# on recupere l'adresse de retour
	
	jr $ra

backtracking_depile : 					# tout depiler
	addi $sp, $sp, 4					# on depile
	lw $t0, 0($sp)						# on recupere le haut de pile
	beq $t0, -1, backtracking_success   # si c'est le -1, on sort
	j backtracking_depile				# sinon on poursuit
	
backtracking_success : 
	lw $t0, 0($sp)						# on recupere le haut de pile
	bne $t0, -1, backtracking_depile	# si c'est le -1, on continue
	addi $sp, $sp, 4					# on depile le -1
	lw $ra, 0($sp)						# on recupere l'adresse de retour
	
	li $v0, 1							# argument de retour

	jr $ra

	


#############################################
#				   							#
# // AFFICHAGE // 							#
#  afficher la grille de sudoku actuelle	#
#				   							#
# Entree :	 								#	
#				   							#
# Sortie : 									#
#############################################

affichage : 
	li $t0, 0				# case courante dans la grille (0 <= .. <=80)
	j print_newseparate		# commencer par l'affichage de la barre en haut
	
print_parcourir :
	lb $a0, grille + 0($t0)				# contenue de la case courante
	li $v0, 1							# affichage de la case courante
	beq $a0, $0, print_parcourir_vide   # si la case contient un 0, on affiche un point (a la place de 0)
	beq $a0, 10, print_parcourir_vide   # si la case contient un 10, on affiche un point (a la place de 10)

	li $v0, 1							# si la case contient un nb 1<=..<=9, on l'affiche
	syscall
	
	j print_parcourir_suite

print_parcourir_vide :					# si la case contient un 0 ou un 10
	la $a0, point						
	li $v0, 4							# on affiche un point
	syscall
	
print_parcourir_suite : 
	la $a0, espace					# afficher un espace ( | ) entre les nb
	li $v0, 4
	syscall
	
	addi $t0, $t0, 1				# mise a jour de l'indice de la case courante

	beq $t0, 81, print_end  		# afficher la ligne finale quand il faut
	
	rem $t1, $t0, 27				# afficher les barres fortes quand il faut
	beq $t1, $0, print_newseparate
	
	rem $t1, $t0, 9					# afficher les barres faibles quand il faut
	beq $t1, $0, print_newline
	
	j print_parcourir
	
print_newline : 
	la $a0, line_normal				# affichage d'une barre separatrice faible
	li $v0, 4
	syscall
	j print_parcourir

print_newseparate : 
	la $a0, line_separate			# affichage d'une barre separatrice forte
	li $v0, 4
	syscall
	j print_parcourir

print_end :
	la $a0, line_end				# affichage de la barre finale
	li $v0, 4
	syscall
	
	jr $ra


