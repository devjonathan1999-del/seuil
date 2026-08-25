extends Node

## Autoload. Suit la couche active et donne accès aux couches automatisées.
## Voir docs/design.md, section 02 et 07.

signal layer_changed(layer: LayerDefinition)

const LAYER_PATHS: Array[String] = [
	"res://resources/layers/tribu.tres",
	"res://resources/layers/village.tres",
	"res://resources/layers/royaume.tres",
	"res://resources/layers/nation.tres",
]

var layers: Array[LayerDefinition] = []
var current_index: int = 0

func _ready() -> void:
	for path in LAYER_PATHS:
		layers.append(load(path) as LayerDefinition)

func get_current_layer() -> LayerDefinition:
	return layers[current_index] if current_index < layers.size() else null

func get_next_layer() -> LayerDefinition:
	var next_index: int = current_index + 1
	return layers[next_index] if next_index < layers.size() else null

## Les couches déjà dépassées, qui tournent en automatisation. Section 07 du doc :
## l'UI ne montre en détail que les plus récentes, le reste se regroupe.
func get_automated_layers() -> Array[LayerDefinition]:
	return layers.slice(0, current_index)

func advance_layer() -> void:
	if current_index < layers.size() - 1:
		current_index += 1
		layer_changed.emit(get_current_layer())

func reset_to_first_layer() -> void:
	current_index = 0
	layer_changed.emit(get_current_layer())

## Production passive en direct, pendant que le joueur joue la couche active.
## Le taux réduit hors-ligne (SaveManager) est un calcul séparé.
func _process(delta: float) -> void:
	var total_rate := 0.0
	for layer in get_automated_layers():
		total_rate += layer.base_rate
	if total_rate > 0.0:
		EconomyManager.add_layer_currency(total_rate * delta)
