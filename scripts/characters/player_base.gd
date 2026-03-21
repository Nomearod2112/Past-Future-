class_name PlayerBase
extends CharacterBody2D

## Shared player logic: movement, interaction detection, input handling.

@export var controls: PlayerControls
@export var move_speed: float = 120.0
@export var era: String = "past"

var can_interact_with: Array[TemporalObject] = []
var current_interaction: TemporalObject = null


func _physics_process(_delta: float) -> void:
	var direction := Vector2(
		Input.get_action_strength(controls.move_right) - Input.get_action_strength(controls.move_left),
		Input.get_action_strength(controls.move_down) - Input.get_action_strength(controls.move_up)
	).normalized()
	velocity = direction * move_speed
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(controls.interact) and can_interact_with.size() > 0:
		_interact_with_nearest()
	elif event.is_action_pressed(controls.journal):
		_toggle_journal()


## Interact with the nearest available temporal object.
func _interact_with_nearest() -> void:
	var nearest: TemporalObject = null
	var min_dist := INF
	for obj in can_interact_with:
		var d := global_position.distance_to(obj.global_position)
		if d < min_dist:
			min_dist = d
			nearest = obj
	if nearest:
		current_interaction = nearest
		nearest.interact(self)


## Toggle the shared journal UI.
func _toggle_journal() -> void:
	# Handled by GameManager
	GameManager.toggle_journal(era)


## Called when entering an interaction area.
func register_interactable(obj: TemporalObject) -> void:
	if obj not in can_interact_with:
		can_interact_with.append(obj)


## Called when leaving an interaction area.
func unregister_interactable(obj: TemporalObject) -> void:
	can_interact_with.erase(obj)
