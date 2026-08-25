class_name TDGrid
extends Node2D

## La grille de jeu et le chemin suivi par les ennemis.
## Un chemin vertical unique pour cette première tranche jouable ;
## le terrain (obstacles, couverture) viendra avec le twist Tribu → Village.

signal cell_clicked(cell: Vector2i)

@export var columns: int = 6
@export var rows: int = 9
@export var cell_size: int = 160
@export var path_column: int = 2

var path: Array[Vector2i] = []

func _ready() -> void:
	for row in rows:
		path.append(Vector2i(path_column, row))
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

func _draw() -> void:
	for row in rows:
		for col in columns:
			var cell := Vector2i(col, row)
			var rect := Rect2(col * cell_size, row * cell_size, cell_size, cell_size)
			var fill_color := Color(0.32, 0.24, 0.12) if is_on_path(cell) else Color(0.16, 0.18, 0.14)
			draw_rect(rect, fill_color, true)
			draw_rect(rect, Color(0.05, 0.05, 0.05), false, 2.0)
