class_name PlayerBase
extends CharacterBody2D

## Shared player logic: movement, interaction detection, input handling.

@export var controls: PlayerControls
@export var move_speed: float = 120.0
@export var era: String = "past"

var can_interact_with: Array[TemporalObject] = []
var current_interaction: TemporalObject = null

@onready var interaction_area: Area2D = $InteractionArea
var _prompt_text: String = ""


func _ready() -> void:
	# Connect interaction area signals to detect nearby temporal objects
	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)


func _process(_delta: float) -> void:
	# Handle interact/journal via Input singleton (works inside SubViewports)
	if Input.is_action_just_pressed(controls.interact):
		print("[", era, "] E/Enter pressed — nearby objects: ", can_interact_with.size())
		if can_interact_with.size() > 0:
			_interact_with_nearest()

	if Input.is_action_just_pressed(controls.journal):
		_toggle_journal()

	# Update interaction prompt
	var old_prompt := _prompt_text
	if can_interact_with.size() > 0:
		var nearest := _get_nearest_interactable()
		if nearest:
			var key := "E" if era == "past" else "Enter"
			_prompt_text = "[" + key + "] " + nearest.interaction_verb
		else:
			_prompt_text = ""
	else:
		_prompt_text = ""
	if _prompt_text != old_prompt:
		queue_redraw()


func _draw() -> void:
	if _prompt_text != "":
		var font := ThemeDB.fallback_font
		var font_size := 10
		var text_size := font.get_string_size(_prompt_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var bg_rect := Rect2(
			Vector2(-text_size.x / 2 - 4, -36 - text_size.y),
			Vector2(text_size.x + 8, text_size.y + 4)
		)
		draw_rect(bg_rect, Color(0, 0, 0, 0.6))
		draw_string(font, Vector2(-text_size.x / 2, -34), _prompt_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(1, 1, 0.8))


func _physics_process(_delta: float) -> void:
	var direction := Vector2(
		Input.get_action_strength(controls.move_right) - Input.get_action_strength(controls.move_left),
		Input.get_action_strength(controls.move_down) - Input.get_action_strength(controls.move_up)
	).normalized()
	velocity = direction * move_speed
	move_and_slide()


## Interact with the nearest available temporal object.
func _interact_with_nearest() -> void:
	var nearest := _get_nearest_interactable()
	if nearest:
		current_interaction = nearest
		nearest.interact(self)


## Toggle the shared journal UI.
func _toggle_journal() -> void:
	GameManager.toggle_journal(era)


## Called when entering an interaction area.
func register_interactable(obj: TemporalObject) -> void:
	if obj not in can_interact_with:
		can_interact_with.append(obj)


## Called when leaving an interaction area.
func unregister_interactable(obj: TemporalObject) -> void:
	can_interact_with.erase(obj)


## Find the nearest interactable object.
func _get_nearest_interactable() -> TemporalObject:
	var nearest: TemporalObject = null
	var min_dist := INF
	for obj in can_interact_with:
		var d := global_position.distance_to(obj.global_position)
		if d < min_dist:
			min_dist = d
			nearest = obj
	return nearest


## When our Area2D overlaps a temporal object's Area2D.
func _on_interaction_area_entered(area: Area2D) -> void:
	print("[", era, "] Area entered: ", area.name, " parent: ", area.get_parent().name)
	var parent := area.get_parent()
	if parent is TemporalObject:
		print("[", era, "] Registered interactable: ", parent.object_id)
		register_interactable(parent as TemporalObject)


## When our Area2D stops overlapping.
func _on_interaction_area_exited(area: Area2D) -> void:
	var parent := area.get_parent()
	if parent is TemporalObject:
		print("[", era, "] Unregistered interactable: ", parent.object_id)
		unregister_interactable(parent as TemporalObject)
