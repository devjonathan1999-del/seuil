class_name TDTower
extends Node2D

## Le comportement au déclenchement dépend des champs renseignés sur la
## définition : buff > slow > splash > mono-cible. Un seul est actif par
## archétype (voir docs/design.md, section 03), donc l'ordre ne crée pas
## d'ambiguïté en pratique.
##
## Sur une couche à tir indirect (Nation), une tourelle sans
## ignores_line_of_sight ignore toute cible qu'un mur lui masque.

var definition: TowerDefinition
var damage_multiplier: float = 1.0

var _range_pixels: float = 0.0
var _splash_radius_pixels: float = 0.0
var _enemies_root: Node2D
var _towers_root: Node2D
var _grid: TDGrid
var _requires_los: bool = false
var _own_cell: Vector2i
var _fire_timer: Timer
var _buff_timer: Timer

func setup(
	tower_definition: TowerDefinition,
	enemies_root: Node2D,
	towers_root: Node2D,
	range_pixels: float,
	splash_radius_pixels: float = 0.0,
	grid: TDGrid = null,
	requires_los: bool = false
) -> void:
	definition = tower_definition
	_enemies_root = enemies_root
	_towers_root = towers_root
	_range_pixels = range_pixels
	_splash_radius_pixels = splash_radius_pixels
	_grid = grid
	_requires_los = requires_los
	if _grid:
		_own_cell = _grid.local_to_grid(_grid.to_local(global_position))

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
		if child is TDEnemy and global_position.distance_to(child.global_position) <= _range_pixels and _can_target(child):
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
			if dist <= _range_pixels and dist < closest_dist and _can_target(child):
				closest = child
				closest_dist = dist
	return closest

## Regroupe les deux conditions de ciblage : ligne de vue (Nation) et
## sol/aérien (Planète). Une tourelle qui ne peut pas voir ou pas
## atteindre l'altitude d'une cible l'ignore complètement.
func _can_target(target: TDEnemy) -> bool:
	if target.definition and target.definition.is_aerial and not definition.can_target_aerial:
		return false
	return _can_see(target)

func _can_see(target: TDEnemy) -> bool:
	if not _requires_los or definition.ignores_line_of_sight or _grid == null:
		return true
	var target_cell: Vector2i = _grid.local_to_grid(_grid.to_local(target.global_position))
	return _grid.has_line_of_sight(_own_cell, target_cell)

## Un symbole différent par rôle (voir docs/design.md, section 03) rend les
## tourelles reconnaissables au premier coup d'œil, sans dépendre que de la
## couleur : plus pour le Support, losange pour le Contrôle, anneau pour
## l'AoE, triangle pour le DPS mono-cible.
func _draw() -> void:
	if definition == null:
		return

	var c: Color = definition.color
	draw_arc(Vector2.ZERO, _range_pixels, 0.0, TAU, 64, Color(c.r, c.g, c.b, 0.16), 1.5)

	draw_circle(Vector2.ZERO, 32.0, Color(0.06, 0.06, 0.07, 0.9))
	draw_circle(Vector2.ZERO, 27.0, c)
	draw_arc(Vector2.ZERO, 27.0, 0.0, TAU, 40, Color(0.0, 0.0, 0.0, 0.35), 2.0)

	var highlight := Color(minf(c.r * 1.5, 1.0), minf(c.g * 1.5, 1.0), minf(c.b * 1.5, 1.0))
	if definition.buff_damage_multiplier > 1.0:
		draw_rect(Rect2(-4.0, -15.0, 8.0, 30.0), highlight, true)
		draw_rect(Rect2(-15.0, -4.0, 30.0, 8.0), highlight, true)
	elif definition.slow_multiplier < 1.0:
		var diamond := PackedVector2Array([Vector2(0, -15), Vector2(15, 0), Vector2(0, 15), Vector2(-15, 0)])
		draw_colored_polygon(diamond, highlight)
	elif _splash_radius_pixels > 0.0:
		draw_arc(Vector2.ZERO, 13.0, 0.0, TAU, 24, highlight, 5.0)
	else:
		var triangle := PackedVector2Array([Vector2(0, -14), Vector2(12, 9), Vector2(-12, 9)])
		draw_colored_polygon(triangle, highlight)
