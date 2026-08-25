class_name TDTower
extends Node2D

## Le comportement au déclenchement dépend des champs renseignés sur la
## définition : buff > slow > splash > mono-cible. Un seul est actif par
## archétype (voir docs/design.md, section 03), donc l'ordre ne crée pas
## d'ambiguïté en pratique.

var definition: TowerDefinition
var damage_multiplier: float = 1.0

var _range_pixels: float = 0.0
var _splash_radius_pixels: float = 0.0
var _enemies_root: Node2D
var _towers_root: Node2D
var _fire_timer: Timer
var _buff_timer: Timer

func setup(tower_definition: TowerDefinition, enemies_root: Node2D, towers_root: Node2D, range_pixels: float, splash_radius_pixels: float = 0.0) -> void:
	definition = tower_definition
	_enemies_root = enemies_root
	_towers_root = towers_root
	_range_pixels = range_pixels
	_splash_radius_pixels = splash_radius_pixels

	_fire_timer = Timer.new()
	_fire_timer.wait_time = 1.0 / definition.fire_rate
	_fire_timer.timeout.connect(_on_fire_timeout)
	add_child(_fire_timer)
	_fire_timer.start()

	queue_redraw()

## Renforce temporairement les dégâts de cette tourelle ; un nouveau pulse
## rafraîchit simplement la durée.
func apply_buff(multiplier: float, duration: float) -> void:
	damage_multiplier = multiplier
	if _buff_timer == null:
		_buff_timer = Timer.new()
		_buff_timer.one_shot = true
		_buff_timer.timeout.connect(func() -> void: damage_multiplier = 1.0)
		add_child(_buff_timer)
	_buff_timer.start(duration)

func _on_fire_timeout() -> void:
	if definition.buff_damage_multiplier > 1.0:
		_pulse_buff_towers()
	elif definition.slow_multiplier < 1.0:
		_pulse_slow_enemies()
	else:
		var target := _find_target()
		if target == null:
			return
		if _splash_radius_pixels > 0.0:
			_deal_splash_damage(target.global_position)
		else:
			target.take_damage(definition.damage * damage_multiplier)

func _pulse_slow_enemies() -> void:
	for child in _enemies_root.get_children():
		if child is TDEnemy and global_position.distance_to(child.global_position) <= _range_pixels:
			child.apply_slow(definition.slow_multiplier, definition.slow_duration)

func _pulse_buff_towers() -> void:
	for child in _towers_root.get_children():
		if child is TDTower and child != self and global_position.distance_to(child.global_position) <= _range_pixels:
			child.apply_buff(definition.buff_damage_multiplier, definition.buff_duration)

## Touche la cible et tout ennemi dans le rayon de la zone autour d'elle.
func _deal_splash_damage(origin: Vector2) -> void:
	for child in _enemies_root.get_children():
		if child is TDEnemy and origin.distance_to(child.global_position) <= _splash_radius_pixels:
			child.take_damage(definition.damage * damage_multiplier)

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
