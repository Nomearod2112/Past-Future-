class_name FutureLena
extends PlayerBase

## Future-Lena (2024) — can investigate, read, climb, and use Echo Vision.

var echo_vision_active: bool = false


func _ready() -> void:
	era = "future"
	visibility_layer = 16
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	if Input.is_action_just_pressed(controls.special):
		_toggle_echo_vision()


## Toggle Echo Vision — shows ghostly traces of past events.
func _toggle_echo_vision() -> void:
	echo_vision_active = !echo_vision_active
