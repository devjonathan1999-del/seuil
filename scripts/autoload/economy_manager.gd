extends Node

## Autoload. Les deux monnaies du jeu : voir docs/design.md, section 04.
## La monnaie de couche se remet à zéro au prestige ; la monnaie de prestige jamais.

signal layer_currency_changed(amount: float)
signal prestige_currency_changed(amount: int)

## Trésor de départ de la toute première couche : sans un premier chantier
## à financer par les combats, la partie serait bloquée avant même de
## commencer. Le pont inter-couches (docs/design.md, section 04) prend le
## relais dès la deuxième couche.
var layer_currency: float = 20.0
var prestige_currency: int = 0

func add_layer_currency(amount: float) -> void:
	layer_currency += amount
	layer_currency_changed.emit(layer_currency)

func spend_layer_currency(amount: float) -> bool:
	if amount > layer_currency:
		return false
	layer_currency -= amount
	layer_currency_changed.emit(layer_currency)
	return true

func add_prestige_currency(amount: int) -> void:
	prestige_currency += amount
	prestige_currency_changed.emit(prestige_currency)

func reset_layer_currency() -> void:
	layer_currency = 0.0
	layer_currency_changed.emit(layer_currency)
