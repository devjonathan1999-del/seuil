extends Node2D

## Assemble la grille, les tourelles, les ennemis et les vagues pour la
## couche active (LayerManager). Choisir un type de tourelle puis toucher
## une case vide et hors chemin l'y pose, si la monnaie de couche suffit.
## Les choix de l'arbre de tech (TechTreeManager) sont appliqués à chaque
## pose, pas rétroactivement. Passer à la couche suivante réinitialise le
## champ de bataille avec le contenu de la nouvelle couche.

## Constante k du pont inter-couches (docs/design.md, section 04) :
## Départ(N+1) = k × √Produit(N).
const BRIDGE_K: float = 2.0

const TOWER_SCENE: PackedScene = preload("res://scenes/td/tower.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/td/enemy.tscn")

@onready var grid: TDGrid = $Grid
@onready var towers_root: Node2D = $Towers
@onready var enemies_root: Node2D = $Enemies
@onready var wave_spawner: TDWaveSpawner = $WaveSpawner
@onready var core_label: Label = $CoreLabel
@onready var wave_label: Label = $WaveLabel
@onready var tower_buttons: Array[Button] = [$TowerButton1, $TowerButton2, $TowerButton3, $TowerButton4]
@onready var tech_button: Button = $TechButton
@onready var tech_tree_panel: Control = $TechTreePanel
@onready var advance_button: Button = $AdvanceButton

var _occupied_cells: Dictionary = {}
var _selected_tower: TowerDefinition
var core_hp: int = 10

func _ready() -> void:
	grid.cell_clicked.connect(_on_cell_clicked)
	tech_button.pressed.connect(func() -> void: tech_tree_panel.visible = not tech_tree_panel.visible)
	advance_button.pressed.connect(_on_advance_pressed)
	EconomyManager.layer_currency_changed.connect(_refresh_affordability)

	for i in tower_buttons.size():
		tower_buttons[i].pressed.connect(_on_tower_button_pressed.bind(i))

	_setup_layer_content()
	_refresh_core_label()

func _on_tower_button_pressed(index: int) -> void:
	var layer: LayerDefinition = LayerManager.get_current_layer()
	var towers: Array[TowerDefinition] = LayerContent.get_towers(layer.id)
	if index < towers.size():
		_select_tower(towers[index])

## (Ré)installe tourelles disponibles, vagues et bouton de progression
## pour la couche active. Appelé au démarrage et à chaque transition.
func _setup_layer_content() -> void:
	var layer: LayerDefinition = LayerManager.get_current_layer()
	var towers: Array[TowerDefinition] = LayerContent.get_towers(layer.id)
	var enemies: Array[EnemyDefinition] = LayerContent.get_enemies(layer.id)

	for i in tower_buttons.size():
		var button: Button = tower_buttons[i]
		if i < towers.size():
			button.visible = true
			button.text = "%s (%d)" % [towers[i].display_name, int(towers[i].cost)]
		else:
			button.visible = false
	if towers.size() > 0:
		_select_tower(towers[0])
	_refresh_affordability(EconomyManager.layer_currency)

	wave_spawner.stop()
	wave_spawner.queue_free()
	var new_spawner := TDWaveSpawner.new()
	add_child(new_spawner)
	wave_spawner = new_spawner
	wave_spawner.enemy_spawned.connect(_on_enemy_spawned)
	wave_spawner.wave_started.connect(_on_wave_started)
	wave_spawner.setup(grid, ENEMY_SCENE, enemies, enemies_root)

	var next_layer: LayerDefinition = LayerManager.get_next_layer()
	if next_layer == null:
		advance_button.visible = false
	else:
		advance_button.visible = true
		advance_button.text = "Passer à %s (%d)" % [next_layer.display_name, int(next_layer.unlock_cost)]

func _select_tower(tower_definition: TowerDefinition) -> void:
	_selected_tower = tower_definition
	var layer: LayerDefinition = LayerManager.get_current_layer()
	var towers: Array[TowerDefinition] = LayerContent.get_towers(layer.id)
	for i in tower_buttons.size():
		if i < towers.size():
			tower_buttons[i].button_pressed = towers[i] == tower_definition

func _refresh_affordability(_amount: float) -> void:
	var layer: LayerDefinition = LayerManager.get_current_layer()
	var towers: Array[TowerDefinition] = LayerContent.get_towers(layer.id)
	for i in tower_buttons.size():
		if i < towers.size():
			tower_buttons[i].disabled = EconomyManager.layer_currency < towers[i].cost
	var next_layer: LayerDefinition = LayerManager.get_next_layer()
	if next_layer:
		advance_button.disabled = EconomyManager.layer_currency < next_layer.unlock_cost

func _on_cell_clicked(cell: Vector2i) -> void:
	if _selected_tower == null or grid.is_on_path(cell) or _occupied_cells.has(cell):
		return
	if not EconomyManager.spend_layer_currency(_selected_tower.cost):
		return

	var effective_definition: TowerDefinition = TechTreeManager.apply_to_definition(_selected_tower)
	var tower: TDTower = TOWER_SCENE.instantiate()
	towers_root.add_child(tower)
	tower.global_position = grid.to_global(grid.grid_to_local(cell))
	tower.setup(
		effective_definition,
		enemies_root,
		towers_root,
		effective_definition.range_cells * grid.cell_size,
		effective_definition.splash_radius_cells * grid.cell_size
	)
	_occupied_cells[cell] = tower

func _on_advance_pressed() -> void:
	var next_layer: LayerDefinition = LayerManager.get_next_layer()
	if next_layer == null:
		return
	if not EconomyManager.spend_layer_currency(next_layer.unlock_cost):
		return

	var bridge_currency: float = BRIDGE_K * sqrt(EconomyManager.total_layer_currency_earned)
	LayerManager.advance_layer()
	EconomyManager.begin_new_layer(bridge_currency)
	_reset_battlefield()

func _reset_battlefield() -> void:
	for child in towers_root.get_children():
		child.queue_free()
	for child in enemies_root.get_children():
		child.queue_free()
	_occupied_cells.clear()
	core_hp = 10
	_refresh_core_label()
	_setup_layer_content()

func _on_wave_started(wave_number: int) -> void:
	wave_label.text = "Vague : %d" % (wave_number + 1)

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
