extends Node

## Autoload. Le reset permanent : voir docs/design.md, section 04 et 05.
## Multiplicateur volontairement sous-linéaire (racine carrée), pour que
## le prestige reste un choix rare et lisible, jamais un axe de farm.

signal prestiged(multiplier: float)

var prestige_points: int = 0

func get_multiplier() -> float:
	return 1.0 + sqrt(float(prestige_points))

func prestige(points_earned: int) -> void:
	prestige_points += points_earned
	LayerManager.reset_to_first_layer()
	EconomyManager.reset_layer_currency()
	EconomyManager.add_prestige_currency(points_earned)
	prestiged.emit(get_multiplier())
