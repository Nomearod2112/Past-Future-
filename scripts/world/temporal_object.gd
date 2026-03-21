class_name TemporalObject
extends Node2D

## Base class for anything affected by the 50-year time gap.
## Every interactable object in the world inherits from this.

@export var object_id: String
@export var grid_position: Vector2i
@export var past_scene: PackedScene
@export var future_scene: PackedScene
@export var interaction_verb: String = "Examine"

var past_instance: Node2D = null
var future_instance: Node2D = null


func _ready() -> void:
	_setup_instances()


## Initialize past and future visual instances.
func _setup_instances() -> void:
	if past_scene:
		past_instance = past_scene.instantiate()
		past_instance.set_meta("era", "past")
		# Layer 2: Past-only objects
		if past_instance is CanvasItem:
			past_instance.visibility_layer = 2
		add_child(past_instance)

	if future_scene:
		future_instance = future_scene.instantiate()
		future_instance.set_meta("era", "future")
		# Layer 3: Future-only objects
		if future_instance is CanvasItem:
			future_instance.visibility_layer = 4
		add_child(future_instance)


## Called when the CausalGraph produces a FutureDelta affecting this object.
func apply_future_delta(delta: FutureDelta) -> void:
	if future_instance:
		future_instance.queue_free()
		future_instance = null

	if delta.add_object_scene:
		future_instance = delta.add_object_scene.instantiate()
		_apply_properties(future_instance, delta.add_object_properties)
		if future_instance is CanvasItem:
			future_instance.visibility_layer = 4
		add_child(future_instance)


## Apply properties dictionary to a node.
func _apply_properties(node: Node2D, properties: Dictionary) -> void:
	for key in properties:
		if node.has_method("set_" + key):
			node.call("set_" + key, properties[key])
		else:
			node.set_meta(key, properties[key])


## Override in subclasses for era-specific interactions.
func interact(player: PlayerBase) -> void:
	if player.era == "past":
		_interact_past(player)
	else:
		_interact_future(player)


## Override: e.g., plant, build, hide.
func _interact_past(_player: PlayerBase) -> void:
	pass


## Override: e.g., dig, read, climb.
func _interact_future(_player: PlayerBase) -> void:
	pass
