extends Panel

@onready var label_icon = $VBoxContainer/LabelIcon
@onready var label_name = $VBoxContainer/LabelName
@onready var label_value = $VBoxContainer/LabelValue

# Fonction qui configure la carte avec les données d'un jeton
func setup(token: TokenResource) -> void:
	label_name.text = token.token_name
	label_value.text = str(token.value)
	
	# On change l'icone et la couleur selon le type
	match token.token_type:
		TokenResource.TokenType.ATTACK:
			label_icon.text = "⚔️"
			self_modulate = Color(1, 0.8, 0.8)  # Change la couleur de fond de la carte selon le type = Rouge clair 
		TokenResource.TokenType.DEFENSE:
			label_icon.text = "🛡️"
			self_modulate = Color(0.8, 0.8, 1)  # Paramètre de couleur = Bleu clair
		TokenResource.TokenType.HAZARD:
			label_icon.text = "💀"
			self_modulate = Color(0.3, 0.3, 0.3)  # Paramètre de couleur = Gris foncé
