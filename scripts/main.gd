extends Control

@onready var status_label: Label = $StatusLabel

func _ready() -> void:
	SaveManager.load_game()
	_refresh_status()
	LayerManager.layer_changed.connect(func(_layer: LayerDefinition) -> void: _refresh_status())
	EconomyManager.layer_currency_changed.connect(func(_amount: float) -> void: _refresh_status())

func _refresh_status() -> void:
	var layer := LayerManager.get_current_layer()
	if layer == null:
		status_label.text = "Aucune couche chargée."
		return

	status_label.text = "%s\nDéfend : %s\nMonnaie de couche : %.0f\nPrestige : %d" % [
		layer.display_name,
		layer.defends,
		EconomyManager.layer_currency,
		EconomyManager.prestige_currency,
	]

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		SaveManager.save_game()
