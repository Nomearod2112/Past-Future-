class_name WorldState
extends Node

## Manages the combined PastState + FutureState of the game world.
## FutureState is always derived from the base map + CausalGraph.

signal future_state_updated()

var causal_graph: CausalGraph
var temporal_objects: Dictionary = {}  # object_id -> TemporalObject


func _ready() -> void:
	causal_graph = CausalGraph.new()
	causal_graph.future_delta_computed.connect(_on_future_delta_computed)


## Register a temporal object with the world state.
func register_object(obj: TemporalObject) -> void:
	temporal_objects[obj.object_id] = obj


## Unregister a temporal object.
func unregister_object(object_id: String) -> void:
	temporal_objects.erase(object_id)


## Get a temporal object by ID.
func get_object(object_id: String) -> TemporalObject:
	return temporal_objects.get(object_id)


## Handle a new FutureDelta from the causal graph.
func _on_future_delta_computed(delta: FutureDelta) -> void:
	# Remove objects marked for removal
	for obj_id in delta.remove_object_ids:
		if temporal_objects.has(obj_id):
			temporal_objects[obj_id].apply_future_delta(delta)

	# Apply the delta to the object at the target position
	for obj_id in temporal_objects:
		var obj: TemporalObject = temporal_objects[obj_id]
		if obj.grid_position == delta.position:
			obj.apply_future_delta(delta)

	future_state_updated.emit()
