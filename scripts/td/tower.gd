class_name TDTower
extends Node2D

var definition: TowerDefinition
var _range_pixels: float = 0.0
var _splash_radius_pixels: float = 0.0
var _enemies_root: Node2D
var _fire_timer: Timer

func setup(tower_definition: TowerDefinition, enemies_root: Node2D, range_pixels: float, splash_radius_pixels: float = 0.0) -> void:
	definition = tower_definition
	_enemies_root = enemies_root
	_range_pixels = range_pixels
	_splash_radius_pixels = splash_radius_pixels

	_fire_timer = Timer.new()
	_fire_timer.wait_time = 1.0 / definition.fire_rate
	_fire_timer.timeout.connect(_on_fire_timeout)
	add_child(_fire_timer)
	_fire_timer.start()

	queue_redraw()

func _on_fire_timeout() -> void:
	var target := _find_target()
	if target == null:
		return

	if _splash_radius_pixels > 0.0:
		_deal_splash_damage(target.global_position)
	else:
		target.take_damage(definition.damage)

## Touche la cible et tout ennemi dans le rayon de la zone autour d'elle.
func _deal_splash_damage(origin: Vector2) -> void:
	for child in _enemies_root.get_children():
		if child is TDEnemy and origin.distance_to(child.global_position) <= _splash_radius_pixels:
			child.take_damage(definition.damage)

func _find_target() -> TDEnemy:
	var closest: TDEnemy = null
	var closest_dist := INF
	for child in _enemies_root.get_children():
		if child is TDEnemy:
			var dist: float = global_position.distance_to(child.global_position)
			if dist <= _range_pixels and dist < closest_dist:
				closest = child
				closest_dist = dist
	return closest

func _draw() -> void:
	if definition == null:
		return
	draw_arc(Vector2.ZERO, _range_pixels, 0.0, TAU, 48, Color(definition.color.r, definition.color.g, definition.color.b, 0.2), 2.0)
	draw_circle(Vector2.ZERO, 28.0, definition.color)
