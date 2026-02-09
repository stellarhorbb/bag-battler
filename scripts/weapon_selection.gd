extends Control

@onready var button_select = $WeaponCards/SwordCard/VBoxContainer/ButtonSelect

# L'arme choisie
var selected_weapon: WeaponResource

func _ready():
	# Charge l'arme Sword
	selected_weapon = load("res://resources/weapons/sword.tres")
	
	# Connexion du bouton
	button_select.pressed.connect(_on_select_pressed)

func _on_select_pressed():
	# On stocke l'arme choisie dans le GameManager
	GameManager.selected_weapon = selected_weapon
	
	# On va vers le combat
	get_tree().change_scene_to_file("res://battle_scene.tscn")
