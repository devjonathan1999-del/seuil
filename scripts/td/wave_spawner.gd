class_name TDWaveSpawner
extends Node

## Vagues continues à intervalle fixe. Scaling par vague : voir docs/design.md,
## section 05 — HP et récompense grossissent en 1.15ⁿ, la vitesse ne bouge pas.

signal enemy_spawned(enemy: TDEnemy)
signal wave_started(wave_number: int)

@export var spawn_interval: float = 1.2
@export var wave_size: int = 5
@export var time_between_waves: float = 4.0
@export var scaling_factor: float = 1.15

var _grid: TDGrid
var _enemy_scene: PackedScene
var _enemy_pool: Array[EnemyDefinition] = []
var _enemies_root: Node2D
var _active: bool = true
var _wave_number: int = 0

func setup(grid: TDGrid, enemy_scene: PackedScene, enemy_pool: Array[EnemyDefinition], enemies_root: Node2D) -> void:
	_grid = grid
	_enemy_scene = enemy_scene
	_enemy_pool = enemy_pool
	_enemies_root = enemies_root
	_run_waves()

func stop() -> void:
	_active = false

func _run_waves() -> void:
	while _active:
		wave_started.emit(_wave_number)
		var stat_scale: float = pow(scaling_factor, _wave_number)

		for i in wave_size:
			if not _active:
				return
			_spawn_enemy(stat_scale)
			await get_tree().create_timer(spawn_interval).timeout

		_wave_number += 1
		if not _active:
			return
		await get_tree().create_timer(time_between_waves).timeout

func _spawn_enemy(stat_scale: float) -> void:
	var enemy_definition: EnemyDefinition = _enemy_pool[randi() % _enemy_pool.size()]
	var enemy: TDEnemy = _enemy_scene.instantiate()
	_enemies_root.add_child(enemy)
	enemy.setup(enemy_definition, _grid.get_path_world_points(), stat_scale)
	enemy_spawned.emit(enemy)
