class_name TokenResource
extends Resource

# Types de jetons possibles, enum est comme un menu déroulant avec des choix possibles
enum TokenType {
	ATTACK, # Fait des dégats
	DEFENSE, # Génère du bouclier
	HAZARD, # Danger
}

# Les propriétés de jetons
@export var token_name: String = "Mon Jeton" # Variable visible dans l'éditeur, avec son nom + valeur par défaut
@export var token_type: TokenType = TokenType.ATTACK # Le type de jeton + valeur par défault
@export var value: int = 1 # La valeur du jeton (nombre entier) + valeur par défault
