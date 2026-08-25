class_name LayerContent
extends RefCounted

## Associe chaque couche à ses 4 tourelles, ses ennemis et son boss éventuel
## (docs/design.md, section 03). Un lookup en code plutôt que des tableaux
## de sous-ressources dans les .tres, plus simple à maintenir à la main
## sans l'éditeur.

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
	&"royaume": [
		"res://resources/towers/arbaletrier.tres",
		"res://resources/towers/bombarde.tres",
		"res://resources/towers/herse.tres",
		"res://resources/towers/heraut.tres",
	],
	&"nation": [
		"res://resources/towers/mitrailleuse.tres",
		"res://resources/towers/artillerie_gaz.tres",
		"res://resources/towers/mines_emp.tres",
		"res://resources/towers/ingenieur.tres",
	],
	&"planete": [
		"res://resources/towers/tourelle_laser.tres",
		"res://resources/towers/frappe_orbitale.tres",
		"res://resources/towers/champ_gravite.tres",
		"res://resources/towers/ia_medicale.tres",
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
	&"royaume": [
		"res://resources/enemies/fantassins.tres",
		"res://resources/enemies/chevalier_lourd.tres",
		"res://resources/enemies/cavalier_leger.tres",
		"res://resources/enemies/trebuchet.tres",
	],
	&"nation": [
		"res://resources/enemies/drones.tres",
		"res://resources/enemies/char_blinde.tres",
		"res://resources/enemies/moto_jet.tres",
		"res://resources/enemies/obusier.tres",
	],
	&"planete": [
		"res://resources/enemies/essaim_insectoides.tres",
		"res://resources/enemies/mecha.tres",
		"res://resources/enemies/intercepteur.tres",
		"res://resources/enemies/croiseur_orbital.tres",
	],
}

## Vagues nommées / boss (twist Village → Royaume). "interval" = une vague
## sur N est une vague de boss (un seul ennemi, pas le tirage habituel).
const BOSS_POOLS: Dictionary = {
	&"royaume": {
		"interval": 5,
		"enemy": "res://resources/enemies/chevalier_noir.tres",
	},
	&"nation": {
		"interval": 5,
		"enemy": "res://resources/enemies/forteresse_mobile.tres",
	},
	&"planete": {
		"interval": 5,
		"enemy": "res://resources/enemies/titan_orbital.tres",
	},
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

static func get_boss_interval(layer_id: StringName) -> int:
	return BOSS_POOLS.get(layer_id, {}).get("interval", 0)

static func get_boss_enemy(layer_id: StringName) -> EnemyDefinition:
	var enemy_path: String = BOSS_POOLS.get(layer_id, {}).get("enemy", "")
	return load(enemy_path) if enemy_path != "" else null
