class_name PastObject
extends TemporalObject

## Object that exists only in the Past era (1974).
## Visible on rendering layer 2.


func _ready() -> void:
	# Past objects only visible on layer 2
	visibility_layer = 2
	super._ready()
