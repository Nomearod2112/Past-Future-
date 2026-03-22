class_name ExamineObject
extends TemporalObject

## Simple examinable object — shows different descriptions per era.

@export var past_description: String = "Nothing special."
@export var future_description: String = "Nothing special."


func _interact_past(_player: PlayerBase) -> void:
	show_feedback(past_description)


func _interact_future(_player: PlayerBase) -> void:
	show_feedback(future_description)
