class_name TDEnemy
extends Node2D

signal died(enemy: TDEnemy)
signal reached_end(enemy: TDEnemy)

var definition: EnemyDefinition
var max_hp: float = 10.0
var speed: float = 90.0
var reward: float = 5.0
var speed_multiplier: float = 1.0

var hp: float
var _path_points: Array[Vector2] = []
var _target_index: int = 1
var _slow_timer: Timer
var _grid: TDGrid

## stat_scale vient du scaling par vague (docs/design.md, section 05) :
## HP et récompense grossissent avec la vague, la vitesse ne bouge pas.
## grid n'est nécessaire que pour les zones de ralentissement (Galactique) ;
## une couche qui n'en a pas peut laisser ce paramètre à null.
func setup(enemy_definition: EnemyDefinition, path_points: Array[Vector2], stat_scale: float = 1.0, grid: TDGrid = null) -> void:
	definition = enemy_definition
	max_hp = enemy_definition.hp * stat_scale
	speed = enemy_definition.speed
	reward = enemy_definition.reward * stat_scale
	hp = max_hp
	_path_points = path_points
	_grid = grid
	if _path_points.size() > 0:
		global_position = _path_points[0]
	add_to_group("enemies")

func _process(delta: float) -> void:
	if _target_index >= _path_points.size():
		return

	var zone_multiplier: float = _grid.get_zone_multiplier_at(global_position) if _grid else 1.0
	var target_point: Vector2 = _path_points[_target_index]
	var to_target: Vector2 = target_point - global_position
	var step: float = speed * speed_multiplier * zone_multiplier * delta

	if to_target.length() <= step:
		global_position = target_point
		_target_index += 1
		if _target_index >= _path_points.size():
			reached_end.emit(self)
			queue_free()
			return
	else:
		global_position += to_target.normalized() * step

	queue_redraw()

## Ralentit l'ennemi ; un nouveau pulse rafraîchit simplement la durée.
func apply_slow(multiplier: float, duration: float) -> void:
	speed_multiplier = multiplier
	if _slow_timer == null:
		_slow_timer = Timer.new()
		_slow_timer.one_shot = true
		_slow_timer.timeout.connect(func() -> void: speed_multiplier = 1.0)
		add_child(_slow_timer)
	_slow_timer.start(duration)

func take_damage(amount: float) -> void:
	hp -= amount
	if hp <= 0.0:
		died.emit(self)
		queue_free()
	else:
		queue_redraw()

func _draw() -> void:
	var radius: float = definition.radius if definition else 24.0
	var color: Color = definition.color if definition else Color(0.7, 0.2, 0.2)
	draw_circle(Vector2.ZERO, radius, color)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 36, Color(0.0, 0.0, 0.0, 0.45), 2.5)
	if definition and definition.is_aerial:
		draw_arc(Vector2.ZERO, radius + 6.0, 0.0, TAU, 32, Color(0.7, 0.9, 1.0, 0.85), 3.0)

	var ratio: float = clamp(hp / max_hp, 0.0, 1.0)
	var bar_width: float = radius * 2.0
	var bar_y: float = -radius - 14.0
	var bar_color: Color
	if ratio > 0.6:
		bar_color = Color(0.35, 0.78, 0.35)
	elif ratio > 0.3:
		bar_color = Color(0.85, 0.75, 0.25)
	else:
		bar_color = Color(0.82, 0.28, 0.24)
	draw_rect(Rect2(-radius, bar_y, bar_width, 7), Color(0.08, 0.08, 0.09, 0.85))
	draw_rect(Rect2(-radius, bar_y, bar_width * ratio, 7), bar_color)
