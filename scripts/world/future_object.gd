class_name FutureObject
extends TemporalObject

## Object that exists only in the Future era (2024).
## Visible on rendering layer 3.


func _ready() -> void:
	# Future objects only visible on layer 3 (bit 3 = value 4)
	visibility_layer = 4
	super._ready()
