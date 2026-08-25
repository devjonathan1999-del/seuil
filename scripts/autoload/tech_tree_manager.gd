extends Node

## Autoload. L'arbre de couche : voir docs/design.md, section 06.
## Deux paliers par tourelle, choix binaire une fois débloqué. Débloquer un
## palier coûte de la monnaie de couche ; une fois débloqué, changer d'option
## (A/B) est gratuit — le respec ne coûte rien, seul le premier accès coûte.
## Remis à zéro à chaque changement de couche (LayerManager.layer_changed).

signal tree_changed

const UNLOCK_COSTS: Array[float] = [20.0, 40.0]

const TIERS: Dictionary = {
	&"chasseur": [
		{"a": {"damage": 1.3}, "b": {"fire_rate": 1.3}},
		{"a": {"range_cells": 1.2}, "b": {"damage": 1.2}},
	],
	&"feu_lance": [
		{"a": {"damage": 1.3}, "b": {"splash_radius_cells": 1.25}},
		{"a": {"fire_rate": 1.2}, "b": {"range_cells": 1.2}},
	],
	&"piege_fosse": [
		{"a": {"slow_multiplier": 0.7}, "b": {"slow_duration": 1.5}},
		{"a": {"range_cells": 1.25}, "b": {"fire_rate": 1.25}},
	],
	&"chaman": [
		{"a": {"buff_damage_multiplier": 1.15}, "b": {"buff_duration": 1.5}},
		{"a": {"range_cells": 1.25}, "b": {"fire_rate": 1.25}},
	],
	&"archer": [
		{"a": {"damage": 1.3}, "b": {"fire_rate": 1.3}},
		{"a": {"range_cells": 1.2}, "b": {"damage": 1.2}},
	],
	&"huile_bouillante": [
		{"a": {"damage": 1.3}, "b": {"splash_radius_cells": 1.25}},
		{"a": {"fire_rate": 1.2}, "b": {"range_cells": 1.2}},
	],
	&"filet": [
		{"a": {"slow_multiplier": 0.7}, "b": {"slow_duration": 1.5}},
		{"a": {"range_cells": 1.25}, "b": {"fire_rate": 1.25}},
	],
	&"forgeron": [
		{"a": {"buff_damage_multiplier": 1.15}, "b": {"buff_duration": 1.5}},
		{"a": {"range_cells": 1.25}, "b": {"fire_rate": 1.25}},
	],
}

var _unlocked: Dictionary = {}
var _choices: Dictionary = {}

func _ready() -> void:
	LayerManager.layer_changed.connect(func(_layer: LayerDefinition) -> void: reset())

func reset() -> void:
	_unlocked.clear()
	_choices.clear()
	tree_changed.emit()

func get_unlock_cost(_tower_id: StringName, tier_index: int) -> float:
	return UNLOCK_COSTS[tier_index] if tier_index < UNLOCK_COSTS.size() else 0.0

func is_unlocked(tower_id: StringName, tier_index: int) -> bool:
	var flags: Array = _unlocked.get(tower_id, [])
	return tier_index < flags.size() and flags[tier_index]

func unlock(tower_id: StringName, tier_index: int) -> void:
	if not _unlocked.has(tower_id):
		_unlocked[tower_id] = []
	while _unlocked[tower_id].size() <= tier_index:
		_unlocked[tower_id].append(false)
	_unlocked[tower_id][tier_index] = true
	tree_changed.emit()

func get_choice(tower_id: StringName, tier_index: int) -> String:
	var choices: Array = _choices.get(tower_id, [])
	return choices[tier_index] if tier_index < choices.size() else ""

func select(tower_id: StringName, tier_index: int, option: String) -> void:
	if not is_unlocked(tower_id, tier_index):
		return
	if not _choices.has(tower_id):
		_choices[tower_id] = []
	while _choices[tower_id].size() <= tier_index:
		_choices[tower_id].append("")
	_choices[tower_id][tier_index] = option
	tree_changed.emit()

## Copie la définition de base avec les choix d'arbre actuels appliqués,
## pour que respec/déblocage n'affecte jamais les tourelles déjà posées.
func apply_to_definition(base: TowerDefinition) -> TowerDefinition:
	var effective: TowerDefinition = base.duplicate()
	var tower_id: StringName = base.id
	var tiers: Array = TIERS.get(tower_id, [])

	for tier_index in tiers.size():
		var choice: String = get_choice(tower_id, tier_index)
		if choice == "":
			continue
		var effects: Dictionary = tiers[tier_index][choice]
		for field in effects:
			effective.set(field, float(effective.get(field)) * float(effects[field]))

	return effective
