extends Panel

## Liste, pour chaque tourelle de la couche active, ses paliers à débloquer
## puis à choisir (A/B). Construit dynamiquement : la structure vient de
## TechTreeManager.TIERS, la liste de tourelles de LayerContent.

const FIELD_LABELS: Dictionary = {
	"damage": "dégâts",
	"fire_rate": "cadence",
	"range_cells": "portée",
	"splash_radius_cells": "rayon de zone",
	"slow_multiplier": "force du ralentissement",
	"slow_duration": "durée du ralentissement",
	"buff_damage_multiplier": "force du bonus",
	"buff_duration": "durée du bonus",
}

@onready var content: VBoxContainer = $Scroll/Content
@onready var close_button: Button = $CloseButton

func _ready() -> void:
	close_button.pressed.connect(func() -> void: visible = false)
	TechTreeManager.tree_changed.connect(_rebuild)
	EconomyManager.layer_currency_changed.connect(func(_amount: float) -> void: _rebuild())
	LayerManager.layer_changed.connect(func(_layer: LayerDefinition) -> void: _rebuild())
	_rebuild()

func _rebuild() -> void:
	for child in content.get_children():
		child.queue_free()

	var layer: LayerDefinition = LayerManager.get_current_layer()
	for tower_definition: TowerDefinition in LayerContent.get_towers(layer.id):
		var header := Label.new()
		header.text = tower_definition.display_name
		header.add_theme_font_size_override("font_size", 24)
		content.add_child(header)

		var tiers: Array = TechTreeManager.TIERS.get(tower_definition.id, [])
		for tier_index in tiers.size():
			content.add_child(_build_tier_row(tower_definition.id, tier_index, tiers[tier_index]))

		content.add_child(HSeparator.new())

func _build_tier_row(tower_id: StringName, tier_index: int, tier: Dictionary) -> Control:
	var row := HBoxContainer.new()

	var label := Label.new()
	label.text = "Palier %d" % (tier_index + 1)
	label.custom_minimum_size = Vector2(120, 0)
	row.add_child(label)

	if not TechTreeManager.is_unlocked(tower_id, tier_index):
		var cost: float = TechTreeManager.get_unlock_cost(tower_id, tier_index)
		var unlock_button := Button.new()
		unlock_button.text = "Débloquer (%d)" % int(cost)
		unlock_button.disabled = EconomyManager.layer_currency < cost
		unlock_button.pressed.connect(func() -> void:
			if EconomyManager.spend_layer_currency(cost):
				TechTreeManager.unlock(tower_id, tier_index)
		)
		row.add_child(unlock_button)
	else:
		for option in ["a", "b"]:
			var option_button := Button.new()
			option_button.toggle_mode = true
			option_button.text = _describe_option(tier[option])
			option_button.button_pressed = TechTreeManager.get_choice(tower_id, tier_index) == option
			option_button.pressed.connect(func() -> void: TechTreeManager.select(tower_id, tier_index, option))
			row.add_child(option_button)

	return row

func _describe_option(effects: Dictionary) -> String:
	var parts: Array[String] = []
	for field in effects:
		var mult: float = effects[field]
		var pct: int = int(round((mult - 1.0) * 100.0))
		parts.append("%s %+d%%" % [FIELD_LABELS.get(field, field), pct])
	return " / ".join(parts)
