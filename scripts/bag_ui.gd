extends Control

# On vient créer des variables et les lier aux différents éléments de l'UI
@onready var label_bag_info = $LabelBagInfo
@onready var label_drawn_token = $LabelDrawnToken
@onready var button_draw = $ButtonDraw
@onready var button_reset = $ButtonReset
@onready var combat_line = $CombatLine 

@onready var label_attack_total = $LabelAttackTotal
@onready var label_defense_total = $LabelDefenseTotal
@onready var label_hazard_warning = $LabelHazardWarning

# On charge la scene du jeton virtuel
var token_card_scene = preload("res://token_card.tscn")

# On importe le noeud de gestionnaire de sac
var bag_manager = BagManager

func _ready():
	bag_manager = BagManager.new() # On crée le BagManager
	add_child(bag_manager)
	
	# On charge les jetons
	var sword = load("res://resources/tokens/basic-sword.tres")
	var shield = load("res://resources/tokens/shield.tres")
	var skull = load("res://resources/tokens/hazard.tres")
	
	# On rempli le sac de départ pour la classe simple
	bag_manager.add_tokens(sword, 4)
	bag_manager.add_tokens(shield, 3)
	bag_manager.add_tokens(skull, 2)
	bag_manager.shuffle()
	
	# On connecte les boutons aux fonctions. .pressed = Signal émis, .connect = Connecte le signal à une fonction, (...) = la fonction à appelerr
	button_draw.pressed.connect(_on_button_draw_pressed)
	button_reset.pressed.connect(_on_button_reset_pressed)
	# Met à jour l'affichage
	update_ui()

# Fonction appelée quand on clique sur "Tirer un jeton"
func _on_button_draw_pressed():
	var token = bag_manager.draw_token()
	
	if token != null:
		# Met à jour le texte
		var type_name = TokenResource.TokenType.keys()[token.token_type]
		label_drawn_token.text = "Dernier jeton tiré: %s (%s, Valeur: %d)" % [token.token_name, type_name, token.value]
		
		# Crée une carte visuelle et l'ajoute à la ligne
		var card = token_card_scene.instantiate() # Crée une nouvelle instance de la carte
		combat_line.add_child(card) # Ajoute la carte à la ligne de combat (elle apparaît à l'écran)
		card.setup(token) # Configure la carte avec les données du jeton tiré
	else:
		label_drawn_token.text = "⚠️ Le sac est vide !"
	# Met à jour l'affichage
	update_ui()
	
# Fonction appelée quand on clique sur "Reset"
func _on_button_reset_pressed():
	bag_manager.reset_bag()
	label_drawn_token.text = "Dernier jeton tiré : - "
	
	# Supprime toutes les cartes de la ligne
	for child in combat_line.get_children():
		child.free()
	
	# Met à jour l'affichage
	update_ui()

# Met à jour l'affichage du nombre de jetons
func update_ui():
	var attack_count = bag_manager.bag.filter(func(t): return t.token_type == TokenResource.TokenType.ATTACK).size()
	var defense_count = bag_manager.bag.filter(func(t): return t.token_type == TokenResource.TokenType.DEFENSE).size()
	var hazard_count = bag_manager.bag.filter(func(t): return t.token_type == TokenResource.TokenType.HAZARD).size()
	
	label_bag_info.text = "📦 Sac: %d jetons (⚔️ %d | 🛡️ %d | 💀 %d)" % [bag_manager.bag.size(), attack_count, defense_count, hazard_count]
	update_combat_line_totals()
	
# Calcule et affiche les totaux de la ligne de combat
func update_combat_line_totals():
	var total_attack = 0
	var total_defense = 0
	var hazard_count = 0
	
	# On parcourt chaque carte présente sur la ligne de combat
	for card in combat_line.get_children():
		# On récupère l'icône de la carte pour savoir son type
		var icon = card.get_node("VBoxContainer/LabelIcon").text
		# On récupère la valeur de la carte et on la convertit en nombre
		var value = int(card.get_node("VBoxContainer/LabelValue").text)
		
		# On additionne dans le bon compteur selon le type
		if icon == "⚔️":
			total_attack += value
		elif icon == "🛡️":
			total_defense += value
		elif icon == "💀":
			hazard_count += 1
	
	# Met à jour le label d'attaque (icône + valeur)
	label_attack_total.text = "⚔️ %d" % total_attack
	
	# Met à jour le label de défense (icône + valeur)
	label_defense_total.text = "🛡️ %d" % total_defense
	
	# Met à jour le label d'avertissement selon le nombre de hazards
	if hazard_count == 0:
		label_hazard_warning.text = ""  # Rien à afficher si pas de hazard
	elif hazard_count == 1:
		label_hazard_warning.text = "⚠️ 1 Hazard - Attention!"
	else:  # 2 hazards ou plus
		label_hazard_warning.text = "💀 CRASH! (%d Hazards)" % hazard_count
