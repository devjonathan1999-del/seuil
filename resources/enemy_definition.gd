class_name EnemyDefinition
extends Resource

## Un archétype d'ennemi, habillé différemment par couche.
## Voir docs/design.md, section 03.

@export var id: StringName
@export var display_name: String
@export var hp: float = 10.0
@export var speed: float = 90.0 ## pixels par seconde
@export var reward: float = 5.0
@export var radius: float = 24.0
@export var color: Color = Color(0.7, 0.2, 0.2)
@export var is_aerial: bool = false ## verticalité (Planète) : ignore murs et Contrôle au sol
