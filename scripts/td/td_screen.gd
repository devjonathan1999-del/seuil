extends Node2D

## Assemble la grille, les tourelles, les ennemis et les vagues.
## Choisir un type de tourelle puis toucher une case vide et hors chemin l'y pose.

const CHASSEUR_TOWER: TowerDefinition = preload("res://resources/towers/chasseur.tres")
const FEU_LANCE_TOWER: TowerDefinition = preload("res://resources/towers/feu_lance.tres")
const LOUPS_ENEMY: EnemyDefinition = preload("res://resources/enemies/loups.tres")
const TOWER_SCENE: PackedScene = preload("res://scenes/td/tower.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/td/enemy.tscn")

@onready var grid: TDGrid = $Grid
@onready var towers_root: Node2D = $Towers
@onready var enemies_root: Node2D = $Enemies
@onready var wave_spawner: TDWaveSpawner = $WaveSpawner
@onready var core_label: Label = $CoreLabel
@onready var chasseur_button: Button = $ChasseurButton
@onready var feu_lance_button: Button = $FeuLanceButton

var _occupied_cells: Dictionary = {}
var _selected_tower: TowerDefinition = CHASSEUR_TOWER
var core_hp: int = 10

func _ready() -> void:
	grid.cell_clicked.connect(_on_cell_clicked)
	wave_spawner.enemy_spawned.connect(_on_enemy_spawned)
	wave_spawner.setup(grid, ENEMY_SCENE, LOUPS_ENEMY, enemies_root)

	chasseur_button.pressed.connect(func() -> void: _select_tower(CHASSEUR_TOWER))
	feu_lance_button.pressed.connect(func() -> void: _select_tower(FEU_LANCE_TOWER))
	_select_tower(CHASSEUR_TOWER)

	_refresh_core_label()

func _select_tower(tower_definition: TowerDefinition) -> void:
	_selected_tower = tower_definition
	chasseur_button.button_pressed = tower_definition == CHASSEUR_TOWER
	feu_lance_button.button_pressed = tower_definition == FEU_LANCE_TOWER

func _on_cell_clicked(cell: Vector2i) -> void:
	if grid.is_on_path(cell) or _occupied_cells.has(cell):
		return

	var tower: TDTower = TOWER_SCENE.instantiate()
	towers_root.add_child(tower)
	tower.global_position = grid.to_global(grid.grid_to_local(cell))
	tower.setup(
		_selected_tower,
		enemies_root,
		_selected_tower.range_cells * grid.cell_size,
		_selected_tower.splash_radius_cells * grid.cell_size
	)
	_occupied_cells[cell] = tower

func _on_enemy_spawned(enemy: TDEnemy) -> void:
	enemy.died.connect(_on_enemy_killed)
	enemy.reached_end.connect(_on_enemy_reached_end)

func _on_enemy_killed(enemy: TDEnemy) -> void:
	EconomyManager.add_layer_currency(enemy.reward)

func _on_enemy_reached_end(_enemy: TDEnemy) -> void:
	if core_hp <= 0:
		return
	core_hp -= 1
	_refresh_core_label()
	if core_hp <= 0:
		wave_spawner.stop()

func _refresh_core_label() -> void:
	core_label.text = "Défaite — cœur détruit" if core_hp <= 0 else "Cœur : %d" % core_hp
