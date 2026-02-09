extends Node

# L'arme sélectionnée par le joueur
var selected_weapon: WeaponResource = null

# Index de l'ennemi actuel (pour la progression)
var current_enemy_index: int = 0

# Liste des ennemis dans l'ordre de progression
var enemy_list: Array[EnemyResource] = []

func _ready():
	# Charge la liste d'ennemis
	enemy_list = [
		load("res://resources/enemies/goblin.tres"),
		load("res://resources/enemies/goblin_elite.tres"),
		load("res://resources/enemies/orc.tres")
	]

func reset_run():
	selected_weapon = null
	current_enemy_index = 0

func get_current_enemy() -> EnemyResource:
	if current_enemy_index < enemy_list.size():
		return enemy_list[current_enemy_index]
	else:
		# Si on a battu tous les ennemis, on boucle sur le dernier
		return enemy_list[enemy_list.size() - 1]

func advance_to_next_enemy():
	current_enemy_index += 1
