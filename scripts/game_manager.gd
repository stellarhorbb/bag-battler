extends Node

# L'arme sélectionnée par le joueur
var selected_weapon: WeaponResource = null

# Index de l'ennemi actuel (pour la progression)
var current_enemy_index: int = 0

func reset_run():
	selected_weapon = null
	current_enemy_index = 0
