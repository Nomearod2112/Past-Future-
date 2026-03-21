class_name FutureLena
extends PlayerBase

## Future-Lena (2024) — can investigate, read, climb, and use Echo Vision.

var echo_vision_active: bool = false


func _ready() -> void:
	era = "future"
	# Layer 5: Future-Lena
	visibility_layer = 16


func _unhandled_input(event: InputEvent) -> void:
	super._unhandled_input(event)
	if event.is_action_pressed(controls.special):
		_toggle_echo_vision()


## Toggle Echo Vision — shows ghostly traces of past events.
func _toggle_echo_vision() -> void:
	echo_vision_active = !echo_vision_active
