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
@export var cost: float = 0.0
@export var color: Color = Color(0.75, 0.55, 0.2)
