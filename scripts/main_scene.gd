extends Control

## Main scene controller — loads the level into both viewports,
## shares World2D between them, and registers players with GameManager.

const HARBOR_DISTRICT := preload("res://scenes/world/harbor_district.tscn")

@onready var world_state: WorldState = $WorldState
@onready var past_viewport: SubViewport = $SplitScreen/PastViewportContainer/PastViewport
@onready var future_viewport: SubViewport = $SplitScreen/FutureViewportContainer/FutureViewport
@onready var past_camera: Camera2D = $SplitScreen/PastViewportContainer/PastViewport/PastCamera
@onready var future_camera: Camera2D = $SplitScreen/FutureViewportContainer/FutureViewport/FutureCamera
@onready var past_lena: PastLena = $SplitScreen/PastViewportContainer/PastViewport/PastLena
@onready var future_lena: FutureLena = $SplitScreen/FutureViewportContainer/FutureViewport/FutureLena


func _ready() -> void:
	# Load the harbor district level into both viewports
	# Add at index 0 so it renders behind the characters
	var past_level := HARBOR_DISTRICT.instantiate()
	past_viewport.add_child(past_level)
	past_viewport.move_child(past_level, 0)

	# Share the same World2D so both viewports render the same world
	future_viewport.world_2d = past_viewport.world_2d

	# Register players with GameManager (WorldState self-registers in _ready)
	GameManager.register_past_lena(past_lena)
	GameManager.register_future_lena(future_lena)

	# Set up the tutorial puzzle
	_setup_puzzles()


func _setup_puzzles() -> void:
	# Register awareness nodes for the garden puzzle
	var garden_note_awareness := AwarenessNode.new()
	garden_note_awareness.id = "garden_note_found"
	garden_note_awareness.required_info_ids = ["garden_note_found"]
	garden_note_awareness.narrative_text = "Past-Lena senses she should plant a tree and hide a key..."
	GameManager.awareness_manager.register_awareness_node(garden_note_awareness)

	# Create and register the tutorial puzzle
	var locked_garden := LockedGarden.new()
	add_child(locked_garden)
	GameManager.puzzle_registry.register_puzzle(locked_garden)
	# Tutorial puzzle has no prerequisites — start as available
	locked_garden.set_state(PuzzleBase.State.AVAILABLE)
	locked_garden.puzzle_solved.connect(_on_puzzle_solved)


func _on_puzzle_solved(puzzle_id: String) -> void:
	print("Puzzle solved: ", puzzle_id)
	GameManager.shared_journal.add_entry(
		"The garden is unlocked! The tree and key worked together across time.",
		"past", true
	)


func _physics_process(_delta: float) -> void:
	# Cameras follow their respective players
	past_camera.global_position = past_lena.global_position
	future_camera.global_position = future_lena.global_position
