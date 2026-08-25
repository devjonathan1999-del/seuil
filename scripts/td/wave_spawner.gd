class_name TDWaveSpawner
extends Node

## Vagues continues à intervalle fixe. Scaling par vague : voir docs/design.md,
## section 05 — HP et récompense grossissent en 1.15ⁿ, la vitesse ne bouge pas.
## Vagues nommées / boss (twist Village → Royaume) : une vague sur
## boss_interval spawn un seul boss au lieu du tirage habituel.

signal enemy_spawned(enemy: TDEnemy)
signal wave_started(wave_number: int, boss_name: String) ## boss_name == "" hors vague de boss

@export var spawn_interval: float = 1.2
@export var wave_size: int = 5
@export var time_between_waves: float = 4.0
@export var scaling_factor: float = 1.15

var _grid: TDGrid
var _enemy_scene: PackedScene
var _enemy_pool: Array[EnemyDefinition] = []
var _boss_enemy: EnemyDefinition
var _boss_interval: int = 0
var _enemies_root: Node2D
var _active: bool = true
var _wave_number: int = 0

func setup(
	grid: TDGrid,
	enemy_scene: PackedScene,
	enemy_pool: Array[EnemyDefinition],
	enemies_root: Node2D,
	boss_enemy: EnemyDefinition = null,
	boss_interval: int = 0
) -> void:
	_grid = grid
	_enemy_scene = enemy_scene
	_enemy_pool = enemy_pool
	_enemies_root = enemies_root
	_boss_enemy = boss_enemy
	_boss_interval = boss_interval
	_run_waves()

func stop() -> void:
	_active = false

func _run_waves() -> void:
	while _active:
		var stat_scale: float = pow(scaling_factor, _wave_number)
		var is_boss_wave: bool = _boss_interval > 0 and _boss_enemy != null and (_wave_number + 1) % _boss_interval == 0
		wave_started.emit(_wave_number, _boss_enemy.display_name if is_boss_wave else "")

		if is_boss_wave:
			_spawn_enemy(stat_scale, _boss_enemy)
		else:
			for i in wave_size:
				if not _active:
					return
				_spawn_enemy(stat_scale, _enemy_pool[randi() % _enemy_pool.size()])
				await get_tree().create_timer(spawn_interval).timeout

		_wave_number += 1
		if not _active:
			return
		await get_tree().create_timer(time_between_waves).timeout

func _spawn_enemy(stat_scale: float, enemy_definition: EnemyDefinition) -> void:
	var enemy: TDEnemy = _enemy_scene.instantiate()
	_enemies_root.add_child(enemy)
	var points: Array[Vector2] = _grid.get_direct_world_points() if enemy_definition.is_aerial else _grid.get_path_world_points()
	enemy.setup(enemy_definition, points, stat_scale)
	enemy_spawned.emit(enemy)
