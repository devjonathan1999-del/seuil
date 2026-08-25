extends Node

## Autoload. Sauvegarde locale et calcul du gain hors-ligne.
## Voir docs/design.md, section 05 : taux réduit, plafonné dans le temps.

const SAVE_PATH := "user://save.dat"
const OFFLINE_RATE := 0.4
const OFFLINE_CAP_SECONDS := 12 * 3600

var last_save_unix_time: int = 0

func save_game() -> void:
	var data := {
		"prestige_points": PrestigeManager.prestige_points,
		"layer_currency": EconomyManager.layer_currency,
		"prestige_currency": EconomyManager.prestige_currency,
		"current_layer_index": LayerManager.current_index,
		"timestamp": Time.get_unix_time_from_system(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(data)

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		last_save_unix_time = Time.get_unix_time_from_system()
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data: Dictionary = file.get_var()
	PrestigeManager.prestige_points = data.get("prestige_points", 0)
	EconomyManager.layer_currency = data.get("layer_currency", 0.0)
	EconomyManager.prestige_currency = data.get("prestige_currency", 0)
	LayerManager.current_index = data.get("current_layer_index", 0)
	last_save_unix_time = data.get("timestamp", Time.get_unix_time_from_system())
	_apply_offline_gains()

func _apply_offline_gains() -> void:
	var elapsed: int = Time.get_unix_time_from_system() - last_save_unix_time
	elapsed = min(elapsed, OFFLINE_CAP_SECONDS)
	if elapsed <= 0:
		return

	var total_rate := 0.0
	for layer: LayerDefinition in LayerManager.get_automated_layers():
		total_rate += layer.base_rate

	if total_rate > 0.0:
		EconomyManager.add_layer_currency(total_rate * OFFLINE_RATE * elapsed)
