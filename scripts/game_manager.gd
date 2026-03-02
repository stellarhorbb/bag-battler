extends Node

var selected_job: JobResource = null
var current_round: int = 1

# Charge la progression de l'entité
var entity_progression: EntityProgressionResource = preload("res://resources/entity/entity_progression.tres")

func reset_run() -> void:
	selected_job = null
	current_round = 1

# Retourne les stats du round actuel
func get_current_stats() -> RoundStatsResource:
	return entity_progression.get_stats(current_round)

# Ante affiché au joueur (calculé automatiquement)
func get_current_ante() -> int:
	return ceil(current_round / 4.0)

# Round dans l'ante (1, 2, 3 ou 4)
func get_round_in_ante() -> int:
	return ((current_round - 1) % 4) + 1

# C'est un boss si c'est le 4ème round de l'ante
func is_boss_round() -> bool:
	return get_round_in_ante() == 4

func advance_round() -> void:
	current_round += 1
