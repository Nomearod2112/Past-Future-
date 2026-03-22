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

signal interacted(player: PlayerBase, temporal_object: TemporalObject)

var _feedback_text: String = ""
var _feedback_timer: float = 0.0


func _ready() -> void:
	_setup_instances()
	# Register with WorldState if available
	if GameManager.world_state:
		GameManager.world_state.register_object(self)


func _process(delta: float) -> void:
	if _feedback_timer > 0:
		_feedback_timer -= delta
		if _feedback_timer <= 0:
			_feedback_text = ""
		queue_redraw()


func _draw() -> void:
	if _feedback_text != "":
		var font := ThemeDB.fallback_font
		var font_size := 10
		var text_size := font.get_string_size(_feedback_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var alpha := clampf(_feedback_timer / 1.0, 0.0, 1.0)
		var bg_rect := Rect2(
			Vector2(-text_size.x / 2 - 4, -30 - text_size.y),
			Vector2(text_size.x + 8, text_size.y + 4)
		)
		draw_rect(bg_rect, Color(0, 0, 0, 0.6 * alpha))
		draw_string(font, Vector2(-text_size.x / 2, -28), _feedback_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(1, 1, 0.8, alpha))


## Initialize past and future visual instances.
func _setup_instances() -> void:
	if past_scene:
		past_instance = past_scene.instantiate()
		past_instance.set_meta("era", "past")
		if past_instance is CanvasItem:
			past_instance.visibility_layer = 2
		add_child(past_instance)

	if future_scene:
		future_instance = future_scene.instantiate()
		future_instance.set_meta("era", "future")
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


## Show floating feedback text on interaction.
func show_feedback(text: String) -> void:
	_feedback_text = text
	_feedback_timer = 2.0
	queue_redraw()


## Override in subclasses for era-specific interactions.
func interact(player: PlayerBase) -> void:
	if player.era == "past":
		_interact_past(player)
	else:
		_interact_future(player)
	interacted.emit(player, self)


## Override: e.g., plant, build, hide.
func _interact_past(_player: PlayerBase) -> void:
	pass


## Override: e.g., dig, read, climb.
func _interact_future(_player: PlayerBase) -> void:
	pass
