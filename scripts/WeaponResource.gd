class_name WeaponResource
extends Resource

# Propriétés de l'arme visibles dans l'éditeur
@export var weapon_name: String = "Sword"
@export var description: String = "For balanced fighters"
@export var difficulty: String = "Easy"

# Le sac de départ (nombre de chaque type de jeton)
@export var starting_attack_tokens: int = 4
@export var starting_defense_tokens: int = 3
@export var starting_hazard_tokens: int = 2

# Passif unique (juste du texte pour l'instant)
@export_multiline var passive_ability: String = "Steady Hand: Le 1er jeton tiré n'est jamais un Hazard."

# Icône de l'arme (pour plus tard)
@export var icon: Texture2D
