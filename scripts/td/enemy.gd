class_name TDEnemy
extends Node2D

signal died(enemy: TDEnemy)
signal reached_end(enemy: TDEnemy)

var max_hp: float = 10.0
var speed: float = 90.0
var reward: float = 5.0

var hp: float
var _path_points: Array[Vector2] = []
var _target_index: int = 1

func setup(definition: EnemyDefinition, path_points: Array[Vector2]) -> void:
	max_hp = definition.hp
	speed = definition.speed
	reward = definition.reward
	hp = max_hp
	_path_points = path_points
	if _path_points.size() > 0:
		global_position = _path_points[0]
	add_to_group("enemies")

func _process(delta: float) -> void:
	if _target_index >= _path_points.size():
		return

	var target_point: Vector2 = _path_points[_target_index]
	var to_target: Vector2 = target_point - global_position
	var step: float = speed * delta

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

func take_damage(amount: float) -> void:
	hp -= amount
	if hp <= 0.0:
		died.emit(self)
		queue_free()
	else:
		queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 24.0, Color(0.7, 0.2, 0.2))
	var ratio: float = clamp(hp / max_hp, 0.0, 1.0)
	draw_rect(Rect2(-24, -38, 48, 6), Color(0.15, 0.15, 0.15))
	draw_rect(Rect2(-24, -38, 48.0 * ratio, 6), Color(0.2, 0.8, 0.3))
