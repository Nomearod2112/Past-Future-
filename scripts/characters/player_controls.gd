class_name PlayerControls
extends Resource

## Decouples input action names from character logic.
## Each player gets their own PlayerControls resource.

@export var move_left: StringName = &"p1_move_left"
@export var move_right: StringName = &"p1_move_right"
@export var move_up: StringName = &"p1_move_up"
@export var move_down: StringName = &"p1_move_down"
@export var interact: StringName = &"p1_interact"
@export var journal: StringName = &"p1_journal"
@export var special: StringName = &"p1_special"
