class_name TDGrid
extends Node2D

## La grille de jeu et le chemin suivi par les ennemis.
## Sans terrain (Tribu) : une voie verticale fixe.
## Avec terrain (Village, docs/design.md section 03) : le chemin le plus
## court est recalculé par A* à chaque construction, et tout ce qu'on pose
## — tourelle ou mur — bloque sa case pour le prochain calcul. Les "portes"
## ne sont pas un objet à part : ce sont les ouvertures qu'on laisse dans
## ses murs pour que le chemin passe encore.

signal cell_clicked(cell: Vector2i)

@export var columns: int = 6
@export var rows: int = 9
@export var cell_size: int = 160
@export var path_column: int = 2

var path: Array[Vector2i] = []
var has_terrain: bool = false

var _astar: AStarGrid2D
var _blocked: Dictionary = {}

func _ready() -> void:
	_rebuild_fixed_path()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cell := local_to_grid(to_local(get_global_mouse_position()))
		if is_in_bounds(cell):
			cell_clicked.emit(cell)

func is_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < columns and cell.y >= 0 and cell.y < rows

func is_on_path(cell: Vector2i) -> bool:
	return path.has(cell)

func grid_to_local(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * cell_size + cell_size / 2.0, cell.y * cell_size + cell_size / 2.0)

func local_to_grid(pos: Vector2) -> Vector2i:
	return Vector2i(int(pos.x / cell_size), int(pos.y / cell_size))

## Points du chemin en coordonnées globales, pour que les ennemis
## puissent les suivre sans dépendre de leur nœud parent.
func get_path_world_points() -> Array[Vector2]:
	var points: Array[Vector2] = []
	for cell in path:
		points.append(to_global(grid_to_local(cell)))
	return points

## Active ou désactive le terrain dynamique pour la couche affichée.
func set_terrain_enabled(enabled: bool) -> void:
	has_terrain = enabled
	_blocked.clear()
	if has_terrain:
		_astar = AStarGrid2D.new()
		_astar.region = Rect2i(0, 0, columns, rows)
		_astar.cell_size = Vector2(cell_size, cell_size)
		_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
		_astar.update()
		_recompute_path()
	else:
		_rebuild_fixed_path()
	queue_redraw()

func get_start_cell() -> Vector2i:
	return Vector2i(path_column, 0)

func get_end_cell() -> Vector2i:
	return Vector2i(path_column, rows - 1)

func is_blocked(cell: Vector2i) -> bool:
	return _blocked.has(cell)

## Vrai si bloquer cette case laisse encore un chemin de bout en bout.
## Utilisé pour les tourelles ET les murs en terrain dynamique : tout ce
## qu'on construit façonne le tracé, personne ne peut le sceller.
func can_block(cell: Vector2i) -> bool:
	if not has_terrain:
		return false
	if is_blocked(cell) or cell == get_start_cell() or cell == get_end_cell():
		return false
	_astar.set_point_solid(cell, true)
	var test_path: Array[Vector2i] = _astar.get_id_path(get_start_cell(), get_end_cell())
	_astar.set_point_solid(cell, false)
	return test_path.size() > 0

func block_cell(cell: Vector2i) -> bool:
	if not can_block(cell):
		return false
	_blocked[cell] = true
	_astar.set_point_solid(cell, true)
	_recompute_path()
	queue_redraw()
	return true

func _recompute_path() -> void:
	path = _astar.get_id_path(get_start_cell(), get_end_cell())

## Vrai si aucune case bloquée ne coupe la ligne entre les deux cases.
## Twist Royaume → Nation : le tir indirect ignore ce résultat.
func has_line_of_sight(from_cell: Vector2i, to_cell: Vector2i) -> bool:
	if not has_terrain:
		return true
	for cell in _cells_on_line(from_cell, to_cell):
		if cell != from_cell and cell != to_cell and is_blocked(cell):
			return false
	return true

func _cells_on_line(a: Vector2i, b: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var x0 := a.x
	var y0 := a.y
	var x1 := b.x
	var y1 := b.y
	var dx := absi(x1 - x0)
	var sx := 1 if x0 < x1 else -1
	var dy := -absi(y1 - y0)
	var sy := 1 if y0 < y1 else -1
	var err := dx + dy
	while true:
		cells.append(Vector2i(x0, y0))
		if x0 == x1 and y0 == y1:
			break
		var e2 := 2 * err
		if e2 >= dy:
			err += dy
			x0 += sx
		if e2 <= dx:
			err += dx
			y0 += sy
	return cells

func _rebuild_fixed_path() -> void:
	path.clear()
	for row in rows:
		path.append(Vector2i(path_column, row))

func _draw() -> void:
	for row in rows:
		for col in columns:
			var cell := Vector2i(col, row)
			var fill_color: Color
			if has_terrain and is_blocked(cell):
				fill_color = Color(0.3, 0.16, 0.1)
			elif is_on_path(cell):
				fill_color = Color(0.32, 0.24, 0.12)
			else:
				fill_color = Color(0.16, 0.18, 0.14)
			var rect := Rect2(col * cell_size, row * cell_size, cell_size, cell_size)
			draw_rect(rect, fill_color, true)
			draw_rect(rect, Color(0.05, 0.05, 0.05), false, 2.0)
