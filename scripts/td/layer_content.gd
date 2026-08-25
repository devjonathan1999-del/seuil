class_name LayerContent
extends RefCounted

## Associe chaque couche à ses 4 tourelles et ses ennemis (docs/design.md,
## section 03). Un lookup en code plutôt que des tableaux de sous-ressources
## dans les .tres, plus simple à maintenir à la main sans l'éditeur.

const TOWER_POOLS: Dictionary = {
	&"tribu": [
		"res://resources/towers/chasseur.tres",
		"res://resources/towers/feu_lance.tres",
		"res://resources/towers/piege_fosse.tres",
		"res://resources/towers/chaman.tres",
	],
	&"village": [
		"res://resources/towers/archer.tres",
		"res://resources/towers/huile_bouillante.tres",
		"res://resources/towers/filet.tres",
		"res://resources/towers/forgeron.tres",
	],
}

const ENEMY_POOLS: Dictionary = {
	&"tribu": [
		"res://resources/enemies/loups.tres",
		"res://resources/enemies/ours.tres",
		"res://resources/enemies/chacal.tres",
	],
	&"village": [
		"res://resources/enemies/pillards.tres",
		"res://resources/enemies/brute_belier.tres",
		"res://resources/enemies/eclaireur_monte.tres",
		"res://resources/enemies/archer_ennemi.tres",
	],
}

static func get_towers(layer_id: StringName) -> Array[TowerDefinition]:
	var result: Array[TowerDefinition] = []
	for path in TOWER_POOLS.get(layer_id, []):
		result.append(load(path))
	return result

static func get_enemies(layer_id: StringName) -> Array[EnemyDefinition]:
	var result: Array[EnemyDefinition] = []
	for path in ENEMY_POOLS.get(layer_id, []):
		result.append(load(path))
	return result
