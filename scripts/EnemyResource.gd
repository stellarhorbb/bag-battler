class_name EnemyResource
extends Resource

# Propriétés de base visibles dans l'éditeur
@export var enemy_name: String = "Goblin"
@export var max_hp: int = 20
@export var base_damage: int = 5

# Propriétés avancées (on les utilisera plus tard)
@export var sprite: Texture2D  # L'image de l'ennemi
@export var intentions: Array[String] = ["attack"]  # Types d'actions possibles
@export var special_ability: String = ""  # Ex: "spiky", "cursed", "foggy"
