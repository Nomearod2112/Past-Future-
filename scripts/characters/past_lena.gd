class_name PastLena
extends PlayerBase

## Past-Lena (1974) — can plant, build, hide objects, and use Blueprint Mode.

var blueprint_mode_active: bool = false


func _ready() -> void:
	era = "past"
	visibility_layer = 8
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	if Input.is_action_just_pressed(controls.special):
		_toggle_blueprint_mode()


## Toggle Blueprint Mode — allows Past-Lena to sketch plans.
func _toggle_blueprint_mode() -> void:
	blueprint_mode_active = !blueprint_mode_active
