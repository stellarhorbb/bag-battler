class_name BagManager
extends Node

# Le sac : une liste qui contient des jetons
var bag: Array[TokenResource] = []
var initial_bag: Array[TokenResource] = []

# On crée une fonction pour ajouter un jeton dans le sac
func add_token(token: TokenResource) -> void:
	bag.append(token)

# On crée une fonction pour ajouter plusieurs jetons dans le sac
func add_tokens(token: TokenResource, count: int) -> void:
	for i in count:
		bag.append(token) # Sauvegarde des jetons dans le sac 
		initial_bag.append(token) # Sauvegarde des jetons dans le sac (pour revenir à l'était initial)
	print("Ajout de %d x %s" % [count, token.token_name])
	
# On affiche tout les jetons qu'il y a dans le sac
func print_bag() -> void:
	print("")
	print("📦 Contenu du sac (%d jetons):" % bag.size())
	
	# Compte combien de jetons de chaque type
	var count_attack = 0
	var count_defense = 0
	var count_hazard = 0
	
	# On parcourt le sac avec un switch ajouter 1 à chaque compteur
	for token in bag:
		match token.token_type:
			TokenResource.TokenType.ATTACK:
				count_attack += 1
			TokenResource.TokenType.DEFENSE:
				count_defense += 1
			TokenResource.TokenType.HAZARD:
				count_hazard += 1
				
	# On affiche les totaux comptés
	print("  - ATTACK: %d" % count_attack)
	print("  - DEFENSE: %d" % count_defense)
	print("  - HAZARD: %d" % count_hazard)
	print("")

# On tire un jeton	
func draw_token() -> TokenResource:
	if bag.is_empty():
		print("Le sac est vide")
		return null

	# Prêt pour les poids — pour l'instant tous à 1.0 donc tirage purement aléatoire
	var total_weight = 0.0
	for token in bag:
		total_weight += token.weight

	var random_value = randf() * total_weight
	var cumulative = 0.0

	var drawn_token: TokenResource = null
	for token in bag:
		cumulative += token.weight
		if random_value <= cumulative:
			drawn_token = token
			break

	bag.erase(drawn_token)

	var type_name = TokenResource.TokenType.keys()[drawn_token.token_type]
	print("Tiré : %s (%s), il reste %d jetons dans le sac" % [drawn_token.token_name, type_name, bag.size()])

	return drawn_token

# Enfin, on remélange le sac
func shuffle() -> void:
	bag.shuffle()
	print("Le sac est mélangé")

# On remet tout les jetons dans le sac
func reset_bag() -> void:
	bag.clear() # Vide le sac actuel
	for token in initial_bag:
		bag.append(token)
	
	shuffle()
	print("Sac réinitialisé (%d jetons)" % bag.size())
	


	
