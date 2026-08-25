class_name TowerDefinition
extends Resource

## Un archétype de tourelle, habillé différemment par couche.
## Voir docs/design.md, section 03 : le rôle reste constant, seul l'habillage change.

@export var id: StringName
@export var display_name: String
@export var damage: float = 2.0
@export var fire_rate: float = 1.0 ## tirs par seconde
@export var range_cells: float = 2.5
@export var splash_radius_cells: float = 0.0 ## 0 = mono-cible, sinon dégâts en zone
@export var slow_multiplier: float = 1.0 ## < 1.0 = ralentit les ennemis à portée (Contrôle)
@export var slow_duration: float = 0.0
@export var buff_damage_multiplier: float = 1.0 ## > 1.0 = renforce les tourelles à portée (Support)
@export var buff_duration: float = 0.0
@export var cost: float = 0.0
@export var color: Color = Color(0.75, 0.55, 0.2)
@export var ignores_line_of_sight: bool = false ## tir indirect (Nation), voir section 03
@export var can_target_aerial: bool = false ## verticalité (Planète), voir section 03
