class_name LayerDefinition
extends Resource

## Une couche de l'escalade civilisationnelle (Tribu, Village, Royaume...).
## Voir docs/design.md, section 02.

@export var id: StringName
@export var display_name: String
@export var defends: String
@export var base_rate: float = 1.0
@export var unlock_cost: float = 0.0
@export var twist_description: String = ""
@export var has_terrain: bool = false ## murs/portes : voir section 03, twist Tribu → Village
@export var requires_line_of_sight: bool = false ## tir indirect : twist Royaume → Nation
@export var has_temporal_zones: bool = false ## ralentissement de zone : twist Planète → Galactique
