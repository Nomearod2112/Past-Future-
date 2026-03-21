extends Node

## Maps P1/P2 inputs. Handles controller assignment and input routing.

var p1_controls: PlayerControls
var p2_controls: PlayerControls


func _ready() -> void:
	p1_controls = PlayerControls.new()
	p1_controls.move_left = &"p1_move_left"
	p1_controls.move_right = &"p1_move_right"
	p1_controls.move_up = &"p1_move_up"
	p1_controls.move_down = &"p1_move_down"
	p1_controls.interact = &"p1_interact"
	p1_controls.journal = &"p1_journal"
	p1_controls.special = &"p1_special"

	p2_controls = PlayerControls.new()
	p2_controls.move_left = &"p2_move_left"
	p2_controls.move_right = &"p2_move_right"
	p2_controls.move_up = &"p2_move_up"
	p2_controls.move_down = &"p2_move_down"
	p2_controls.interact = &"p2_interact"
	p2_controls.journal = &"p2_journal"
	p2_controls.special = &"p2_special"
