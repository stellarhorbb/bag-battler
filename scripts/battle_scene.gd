extends Control

# Références UI existantes
@onready var label_bag_info = $LabelBagInfo
@onready var label_drawn_token = $LabelDrawnToken
@onready var button_draw = $ButtonDraw
@onready var button_execute = $ButtonExecute
@onready var button_reset = $ButtonReset
@onready var combat_line = $CombatLine 
@onready var label_attack_total = $LabelAttackTotal
@onready var label_defense_total = $LabelDefenseTotal
@onready var label_hazard_warning = $LabelHazardWarning

# Références UI Ennemi
@onready var label_enemy_name = $EnemyZone/LabelEnemyName
@onready var label_enemy_hp = $EnemyZone/LabelEnemyHP
@onready var label_enemy_intention = $EnemyZone/LabelEnemyIntention

# Références UI Joueur
@onready var label_player_hp = $PlayerHPZone/LabelPlayerHP

# Scène du jeton virtuel
var token_card_scene = preload("res://token_card.tscn")

# Gestionnaire de sac
var bag_manager = BagManager

# L'ennemi actuel
var current_enemy: Enemy

# HP du joueur (AJOUTE CES LIGNES)
var player_max_hp: int = 20
var player_current_hp: int = 20

func _ready():
	# Création du BagManager
	bag_manager = BagManager.new()
	add_child(bag_manager)
	
	# Chargement des jetons de base
	var attack_token = load("res://resources/tokens/attack.tres")
	var defense_token = load("res://resources/tokens/defense.tres")
	var hazard_token = load("res://resources/tokens/hazard.tres")

	# Récupère l'arme choisie (ou Knight par défaut si on lance directement la scène)
	var weapon = GameManager.selected_weapon
	if weapon == null:
		weapon = load("res://resources/weapons/sword.tres")

	# Remplissage du sac selon l'arme choisie
	bag_manager.add_tokens(attack_token, weapon.starting_attack_tokens)
	bag_manager.add_tokens(defense_token, weapon.starting_defense_tokens)
	bag_manager.add_tokens(hazard_token, weapon.starting_hazard_tokens)
	
	# Création de l'ennemi
	setup_enemy()
	
	# Connexion des boutons
	button_draw.pressed.connect(_on_button_draw_pressed)
	button_execute.pressed.connect(_on_button_execute_pressed)
	button_reset.pressed.connect(_on_button_reset_pressed)
	
	# Mise à jour de l'affichage
	update_ui()
	update_player_hp()

# Fonction pour créer et configurer l'ennemi
func setup_enemy() -> void:
	var goblin_data = load("res://resources/enemies/goblin.tres")
	current_enemy = Enemy.new()
	add_child(current_enemy)
	current_enemy.setup(goblin_data)
	current_enemy.hp_changed.connect(_on_enemy_hp_changed)
	current_enemy.intention_changed.connect(_on_enemy_intention_changed)
	current_enemy.enemy_died.connect(_on_enemy_died)
	
	label_enemy_name.text = goblin_data.enemy_name
	label_enemy_hp.text = "HP: %d / %d" % [current_enemy.current_hp, goblin_data.max_hp]
	label_enemy_intention.text = "💢 Attaque: %d" % current_enemy.current_damage

# Fonction appelée quand on clique sur "Tirer un jeton"
func _on_button_draw_pressed():
	var token = bag_manager.draw_token()
	
	if token != null:
		var type_name = TokenResource.TokenType.keys()[token.token_type]
		label_drawn_token.text = "Dernier jeton tiré: %s (%s, Valeur: %d)" % [token.token_name, type_name, token.value]
		
		# Crée une carte visuelle et l'ajoute à la ligne
		var card = token_card_scene.instantiate()
		combat_line.add_child(card)
		card.setup(token)
		
		# Met à jour l'affichage
		update_ui()
		
		# NOUVEAU : Vérification immédiate du Crash
		var hazard_count = 0
		for c in combat_line.get_children():
			var icon = c.get_node("VBoxContainer/LabelIcon").text
			if icon == "💀":
				hazard_count += 1
		
		# Si 2 Hazards ou plus → CRASH IMMÉDIAT !
		if hazard_count >= 2:
			print("💥 CRASH IMMÉDIAT ! Le joueur est stunné !")
			label_drawn_token.text = "💥 CRASH ! Tour perdu, vous prenez tous les dégâts !"
			
			# Le joueur prend TOUS les dégâts ennemis (pas de défense)
			var incoming_damage = current_enemy.current_damage
			print("💀 Dégâts reçus sans défense : %d" % incoming_damage)
			
			player_current_hp -= incoming_damage
			player_current_hp = max(player_current_hp, 0)
			update_player_hp()
			
			# Vérifie si le joueur est mort
			if player_current_hp <= 0:
				print("💀 DÉFAITE ! Le joueur est mort !")
				label_drawn_token.text = "💀 DÉFAITE ! Vous avez été vaincu..."
				button_draw.disabled = true
				button_execute.disabled = true
				return
			
			# L'ennemi prépare sa prochaine intention
			current_enemy.prepare_next_intention()
			
			# Nettoyage automatique de la ligne
			for child in combat_line.get_children():
				var icon = child.get_node("VBoxContainer/LabelIcon").text
				var value = int(child.get_node("VBoxContainer/LabelValue").text)
				
				# Remet le jeton dans le sac
				for t in bag_manager.initial_bag:
					var type_match = false
					match icon:
						"⚔️":
							type_match = (t.token_type == TokenResource.TokenType.ATTACK)
						"🛡️":
							type_match = (t.token_type == TokenResource.TokenType.DEFENSE)
						"💀":
							type_match = (t.token_type == TokenResource.TokenType.HAZARD)
					
					if type_match and t.value == value:
						bag_manager.bag.append(t)
						break
				
				child.queue_free()
			
			# Mélange du sac
			bag_manager.shuffle()
			update_ui()
			
			print("=== FIN DU TOUR (CRASH) ===")
			print("")
	else:
		label_drawn_token.text = "⚠️ Le sac est vide !"
		update_ui()

# Fonction appelée quand on clique sur "EXÉCUTER"
func _on_button_execute_pressed():
	print("=== PHASE D'EXÉCUTION ===")
	
	var total_attack = 0
	var total_defense = 0
	var _hazard_count = 0
	var tokens_to_return = []  # Liste des jetons à remettre dans le sac
	
	# 1. Calcul des totaux ET récupération des jetons
	for card in combat_line.get_children():
		var icon = card.get_node("VBoxContainer/LabelIcon").text
		var value = int(card.get_node("VBoxContainer/LabelValue").text)
		
		# Trouve le jeton correspondant
		for token in bag_manager.initial_bag:
			if token.value == value:
				var type_match = false
				match icon:
					"⚔️":
						type_match = (token.token_type == TokenResource.TokenType.ATTACK)
					"🛡️":
						type_match = (token.token_type == TokenResource.TokenType.DEFENSE)
					"💀":
						type_match = (token.token_type == TokenResource.TokenType.HAZARD)
				
				if type_match:
					tokens_to_return.append(token)
					break
		
		# Calcul des totaux
		if icon == "⚔️":
			total_attack += value
		elif icon == "🛡️":
			total_defense += value
		elif icon == "💀":
			_hazard_count += 1
	
	# 3. Application des dégâts
	print("Joueur inflige %d dégâts à l'ennemi" % total_attack)
	current_enemy.take_damage(total_attack)
	
	# 4. Attaque ennemie (si pas mort)
	if current_enemy.current_hp > 0:
		var incoming_damage = max(0, current_enemy.current_damage - total_defense)
		print("Ennemi attaque pour %d (défense joueur: %d) = %d dégâts reçus" % [current_enemy.current_damage, total_defense, incoming_damage])
		
		# Applique les dégâts au joueur
		player_current_hp -= incoming_damage
		player_current_hp = max(player_current_hp, 0)  # Ne descend pas en dessous de 0
		update_player_hp()
		
		# Vérifie si le joueur est mort
		if player_current_hp <= 0:
			print("💀 DÉFAITE ! Le joueur est mort !")
			label_drawn_token.text = "💀 DÉFAITE ! Vous avez été vaincu..."
			# On désactive les boutons pour empêcher de continuer
			button_draw.disabled = true
			button_execute.disabled = true
			return  # On arrête la fonction ici
		
		# Prépare la prochaine intention
		current_enemy.prepare_next_intention()
	
	# 5. Suppression des cartes visuelles
	for child in combat_line.get_children():
		child.queue_free()
	
	# 6. Remise des jetons dans le sac
	for token in tokens_to_return:
		bag_manager.bag.append(token)
	
	# 7. Mélange du sac
	bag_manager.shuffle()
	
	print("=== FIN DU TOUR ===")
	print("")
	
	update_ui()
	
# Fonction appelée quand on clique sur "Reset"
func _on_button_reset_pressed():
	bag_manager.reset_bag()
	label_drawn_token.text = "Dernier jeton tiré : - "
	
	# Réactive les boutons 
	button_draw.disabled = false
	button_execute.disabled = false
	
	# Reset les HP du joueur
	player_current_hp = player_max_hp
	update_player_hp()
	
	for child in combat_line.get_children():
		child.free()
	
	if current_enemy:
		current_enemy.queue_free()
	setup_enemy()
	
	update_ui()

# Mise à jour de l'affichage du sac
func update_ui():
	var attack_count = bag_manager.bag.filter(func(t): return t.token_type == TokenResource.TokenType.ATTACK).size()
	var defense_count = bag_manager.bag.filter(func(t): return t.token_type == TokenResource.TokenType.DEFENSE).size()
	var hazard_count = bag_manager.bag.filter(func(t): return t.token_type == TokenResource.TokenType.HAZARD).size()
	
	label_bag_info.text = "📦 Sac: %d jetons (⚔️ %d | 🛡️ %d | 💀 %d)" % [bag_manager.bag.size(), attack_count, defense_count, hazard_count]
	update_combat_line_totals()
	
# Met à jour l'affichage des HP du joueur
func update_player_hp() -> void:
	label_player_hp.text = "HP: %d / %d" % [player_current_hp, player_max_hp]
	
	# Change la couleur selon l'état de santé
	if player_current_hp <= 0:
		label_player_hp.modulate = Color(0.5, 0.5, 0.5)  # Gris si mort
	elif player_current_hp <= player_max_hp * 0.3:
		label_player_hp.modulate = Color(1, 0.3, 0.3)  # Rouge foncé si critique
	else:
		label_player_hp.modulate = Color(1, 0.5, 0.5)  # Rouge normal

# Calcule et affiche les totaux de la ligne de combat
func update_combat_line_totals():
	var total_attack = 0
	var total_defense = 0
	var hazard_count = 0
	
	for card in combat_line.get_children():
		var icon = card.get_node("VBoxContainer/LabelIcon").text
		var value = int(card.get_node("VBoxContainer/LabelValue").text)
		
		if icon == "⚔️":
			total_attack += value
		elif icon == "🛡️":
			total_defense += value
		elif icon == "💀":
			hazard_count += 1
	
	label_attack_total.text = "⚔️ %d" % total_attack
	label_defense_total.text = "🛡️ %d" % total_defense
	
	if hazard_count == 0:
		label_hazard_warning.text = ""
	elif hazard_count == 1:
		label_hazard_warning.text = "⚠️ 1 Hazard - Attention!"
	else:
		label_hazard_warning.text = "💀 CRASH! (%d Hazards)" % hazard_count

# Callbacks pour les signaux de l'ennemi
func _on_enemy_hp_changed(new_hp: int, max_hp: int) -> void:
	label_enemy_hp.text = "HP: %d / %d" % [new_hp, max_hp]

func _on_enemy_intention_changed(_intention_type: String, damage: int) -> void:
	label_enemy_intention.text = "💢 Attaque: %d" % damage

func _on_enemy_died() -> void:
	label_drawn_token.text = "🎉 VICTOIRE ! L'ennemi est vaincu !"
	print("=== COMBAT TERMINÉ : VICTOIRE ===")
