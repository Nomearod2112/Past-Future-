class_name PropagationRule
extends Resource

## Defines what a Past action becomes in the Future.

@export var event_type: CausalEvent.Type
@export var base_future_object_scene: PackedScene
@export var aging_curve: Curve


## Override this for custom logic per event type.
func apply(event: CausalEvent, nearby: Array[CausalEvent]) -> FutureDelta:
	var delta := FutureDelta.new()
	delta.position = event.position
	delta.remove_object_ids = _get_replaced_objects(event)
	delta.add_object_scene = base_future_object_scene
	delta.add_object_properties = _compute_properties(event, nearby)
	return delta


## Determine which existing objects this event replaces.
func _get_replaced_objects(event: CausalEvent) -> Array[String]:
	var ids: Array[String] = []
	if event.target_object_id != "":
		ids.append(event.target_object_id)
	return ids


## Compute properties for the future object based on event and nearby interactions.
func _compute_properties(_event: CausalEvent, nearby: Array[CausalEvent]) -> Dictionary:
	var props := {}
	for n in nearby:
		if n.type == CausalEvent.Type.REDIRECT_WATER:
			props["size_multiplier"] = 1.3
	return props
