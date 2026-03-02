class_name BaseEffect
extends Resource

# Chaque effet reçoit le contexte complet du combat
# et modifie le ResolveResult en conséquence
func apply(context: CombatContext) -> void:
	pass  # Surchargé par chaque effet
