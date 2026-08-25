class_name EnemyDefinition
extends Resource

## Un archétype d'ennemi, habillé différemment par couche.
## Voir docs/design.md, section 03.

@export var id: StringName
@export var display_name: String
@export var hp: float = 10.0
@export var speed: float = 90.0 ## pixels par seconde
@export var reward: float = 5.0
