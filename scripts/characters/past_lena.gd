class_name PastLena
extends PlayerBase

## Past-Lena (1974) — can plant, build, hide objects, and use Blueprint Mode.

var blueprint_mode_active: bool = false


func _ready() -> void:
	era = "past"
	# Layer 4: Past-Lena
	visibility_layer = 8


func _unhandled_input(event: InputEvent) -> void:
	super._unhandled_input(event)
	if event.is_action_pressed(controls.special):
		_toggle_blueprint_mode()


## Toggle Blueprint Mode — allows Past-Lena to sketch plans.
func _toggle_blueprint_mode() -> void:
	blueprint_mode_active = !blueprint_mode_active
