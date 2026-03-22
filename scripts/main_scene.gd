extends Control

## Main scene controller — loads the level, manages HUD, intro, and puzzle flow.

const HARBOR_DISTRICT := preload("res://scenes/world/harbor_district.tscn")

@onready var world_state: WorldState = $WorldState
@onready var split_screen: HBoxContainer = $SplitScreen
@onready var past_viewport: SubViewport = $SplitScreen/PastViewportContainer/PastViewport
@onready var future_viewport: SubViewport = $SplitScreen/FutureViewportContainer/FutureViewport
@onready var past_camera: Camera2D = $SplitScreen/PastViewportContainer/PastViewport/PastCamera
@onready var future_camera: Camera2D = $SplitScreen/FutureViewportContainer/FutureViewport/FutureCamera
@onready var past_lena: PastLena = $SplitScreen/PastViewportContainer/PastViewport/PastLena
@onready var future_lena: FutureLena = $SplitScreen/FutureViewportContainer/FutureViewport/FutureLena
@onready var divider: ColorRect = $SplitScreen/Divider

var _hud_layer: CanvasLayer
var _past_era_label: Label
var _future_era_label: Label
var _objective_label: Label
var _narrative_label: Label
var _narrative_bg: ColorRect
var _locked_garden: LockedGarden
var _puzzle_solved: bool = false
var _intro_done: bool = false


func _ready() -> void:
	# Register divider for ripple effect access
	divider.add_to_group("temporal_divider")

	# Load level
	var past_level := HARBOR_DISTRICT.instantiate()
	past_viewport.add_child(past_level)
	past_viewport.move_child(past_level, 0)
	future_viewport.world_2d = past_viewport.world_2d

	# Register players
	GameManager.register_past_lena(past_lena)
	GameManager.register_future_lena(future_lena)

	# Build HUD
	_setup_hud()

	# Setup puzzle
	_setup_puzzles()

	# Connect awareness to puzzle updates
	GameManager.awareness_manager.awareness_unlocked.connect(_on_awareness_unlocked)

	# Connect journal for narrative moments
	GameManager.shared_journal.entry_added.connect(_on_journal_entry)

	# Start intro sequence
	_play_intro()


func _setup_hud() -> void:
	_hud_layer = CanvasLayer.new()
	_hud_layer.layer = 100
	add_child(_hud_layer)

	# Era label — Past (top-left)
	_past_era_label = Label.new()
	_past_era_label.text = "1974 — PAST"
	_past_era_label.position = Vector2(16, 8)
	_past_era_label.add_theme_font_size_override("font_size", 16)
	_past_era_label.add_theme_color_override("font_color", Color(0.831, 0.627, 0.337, 0.9))
	_hud_layer.add_child(_past_era_label)

	# Era label — Future (top-right area)
	_future_era_label = Label.new()
	_future_era_label.text = "2024 — FUTURE"
	_future_era_label.position = Vector2(660, 8)
	_future_era_label.add_theme_font_size_override("font_size", 16)
	_future_era_label.add_theme_color_override("font_color", Color(0.478, 0.608, 0.71, 0.9))
	_hud_layer.add_child(_future_era_label)

	# Objective text (bottom center)
	_objective_label = Label.new()
	_objective_label.text = ""
	_objective_label.position = Vector2(0, 680)
	_objective_label.size = Vector2(1280, 40)
	_objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_objective_label.add_theme_font_size_override("font_size", 13)
	_objective_label.add_theme_color_override("font_color", Color(0.94, 0.87, 0.7, 0.9))
	_hud_layer.add_child(_objective_label)

	# Narrative overlay (center, for intro and story moments)
	_narrative_bg = ColorRect.new()
	_narrative_bg.color = Color(0, 0, 0, 0.85)
	_narrative_bg.position = Vector2(0, 0)
	_narrative_bg.size = Vector2(1280, 720)
	_narrative_bg.visible = false
	_hud_layer.add_child(_narrative_bg)

	_narrative_label = Label.new()
	_narrative_label.text = ""
	_narrative_label.position = Vector2(140, 200)
	_narrative_label.size = Vector2(1000, 400)
	_narrative_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_narrative_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_narrative_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_narrative_label.add_theme_font_size_override("font_size", 20)
	_narrative_label.add_theme_color_override("font_color", Color(0.94, 0.87, 0.7, 1))
	_hud_layer.add_child(_narrative_label)


func _play_intro() -> void:
	_narrative_bg.visible = true
	_narrative_label.visible = true
	past_lena.set_physics_process(false)
	future_lena.set_physics_process(false)
	past_lena.set_process(false)
	future_lena.set_process(false)

	# Beat 1: Title
	_narrative_label.text = "PAST & FUTURE"
	_narrative_label.add_theme_font_size_override("font_size", 32)
	await get_tree().create_timer(2.5).timeout

	# Beat 2: Setting
	_narrative_label.add_theme_font_size_override("font_size", 18)
	_narrative_label.text = "Halvmane, a small coastal town.\n\nTwo versions of the same woman explore it — separated by 50 years.\n\nWhat she does in 1974 shapes what exists in 2024.\nWhat she discovers in 2024 guides what she does in 1974."
	await get_tree().create_timer(5.0).timeout

	# Beat 3: Controls
	_narrative_label.text = "PAST-LENA (Left)                    FUTURE-LENA (Right)\nWASD to move                         Arrow keys to move\nE to interact                              Enter to interact\nTab for journal                          Backspace for journal"
	await get_tree().create_timer(4.0).timeout

	# Beat 4: First objective
	_narrative_label.add_theme_font_size_override("font_size", 20)
	_narrative_label.text = "Chapter 1: The Locked Garden\n\nFuture-Lena has heard about an old garden on the east side of town.\nThere's a faded note near the fence. Maybe it holds a clue..."
	await get_tree().create_timer(4.0).timeout

	# Fade out
	var tween := create_tween()
	tween.tween_property(_narrative_bg, "color:a", 0.0, 1.0)
	tween.parallel().tween_property(_narrative_label, "modulate:a", 0.0, 1.0)
	await tween.finished

	_narrative_bg.visible = false
	_narrative_label.visible = false
	_narrative_label.modulate.a = 1.0
	_intro_done = true

	past_lena.set_physics_process(true)
	future_lena.set_physics_process(true)
	past_lena.set_process(true)
	future_lena.set_process(true)

	_update_objective("Future-Lena: Find and read the note near the garden fence (east side)")


func _setup_puzzles() -> void:
	# Register awareness nodes
	var garden_note_awareness := AwarenessNode.new()
	garden_note_awareness.id = "garden_note_found"
	garden_note_awareness.required_info_ids = ["garden_note_found"]
	garden_note_awareness.narrative_text = "Past-Lena senses she should plant a tree and hide a key..."
	GameManager.awareness_manager.register_awareness_node(garden_note_awareness)

	# Create and register the tutorial puzzle
	_locked_garden = LockedGarden.new()
	add_child(_locked_garden)
	GameManager.puzzle_registry.register_puzzle(_locked_garden)
	_locked_garden.set_state(PuzzleBase.State.AVAILABLE)
	_locked_garden.puzzle_solved.connect(_on_puzzle_solved)


func _on_awareness_unlocked(node: AwarenessNode) -> void:
	# Re-check puzzles when awareness changes
	if world_state:
		GameManager.puzzle_registry.update_all(
			world_state.causal_graph, GameManager.awareness_manager
		)

	# Narrative moment: note found
	if node.id == "garden_note_found":
		_show_narrative(node.narrative_text, 2.5)
		_update_objective(
			"Past-Lena: Plant the sapling (garden) and hide the key (rocks south of garden)"
		)


func _on_journal_entry(entry: SharedJournal.JournalEntry) -> void:
	# Check puzzle progress after each journal entry
	if world_state and not _puzzle_solved:
		GameManager.puzzle_registry.update_all(
			world_state.causal_graph, GameManager.awareness_manager
		)

	# Update objectives based on progress
	if _locked_garden and not _puzzle_solved:
		var tree_done: bool = _locked_garden.progress.get("tree_planted", false)
		var key_done: bool = _locked_garden.progress.get("key_hidden", false)
		if tree_done and not key_done:
			_update_objective("Past-Lena: Now hide the garden key under the rocks")
		elif key_done and not tree_done:
			_update_objective("Past-Lena: Now plant the sapling in the garden")


func _on_puzzle_solved(puzzle_id: String) -> void:
	_puzzle_solved = true

	# Celebrate!
	_update_objective("")
	_show_narrative(
		"The Locked Garden — SOLVED!\n\n"
		+ "The tree Past-Lena planted grew tall over 50 years.\n"
		+ "The key she buried survived in its metal box.\n"
		+ "The garden gate swings open. Time bridges past and future.",
		6.0
	)

	# Update garden gate visuals
	var gate_past := _find_polygon("GardenGatePast")
	var gate_lock := _find_polygon("GardenGateLock")
	var gate_future := _find_polygon("GardenGateFuture")
	var gate_rust := _find_polygon("GardenGateRust")
	if gate_past:
		gate_past.color = Color(0.3, 0.6, 0.3, 0.5)
	if gate_lock:
		gate_lock.visible = false
	if gate_future:
		gate_future.color = Color(0.3, 0.5, 0.3, 0.5)
	if gate_rust:
		gate_rust.visible = false

	# Flash divider gold
	if divider:
		var tween := create_tween()
		tween.tween_property(divider, "color", Color(1, 0.9, 0.4, 1), 0.3)
		tween.tween_property(divider, "color", Color(0.941, 0.78, 0.369, 1), 1.0)

	GameManager.shared_journal.add_entry(
		"The garden is unlocked! The tree and key worked together across time.",
		"past", true
	)


func _show_narrative(text: String, duration: float) -> void:
	_narrative_bg.visible = true
	_narrative_bg.color = Color(0, 0, 0, 0.8)
	_narrative_label.visible = true
	_narrative_label.text = text
	_narrative_label.add_theme_font_size_override("font_size", 18)

	await get_tree().create_timer(duration).timeout

	var tween := create_tween()
	tween.tween_property(_narrative_bg, "color:a", 0.0, 0.8)
	tween.parallel().tween_property(_narrative_label, "modulate:a", 0.0, 0.8)
	await tween.finished

	_narrative_bg.visible = false
	_narrative_label.visible = false
	_narrative_label.modulate.a = 1.0


func _update_objective(text: String) -> void:
	if _objective_label:
		_objective_label.text = text


func _find_polygon(node_name: String) -> Polygon2D:
	var nodes := get_tree().get_nodes_in_group("temporal_objects")
	# Search through all nodes in the past viewport
	var search_root := past_viewport
	if search_root:
		return _find_child_polygon(search_root, node_name)
	return null


func _find_child_polygon(node: Node, target: String) -> Polygon2D:
	if node.name == target and node is Polygon2D:
		return node as Polygon2D
	for child in node.get_children():
		var result := _find_child_polygon(child, target)
		if result:
			return result
	return null


func _physics_process(_delta: float) -> void:
	past_camera.global_position = past_lena.global_position
	future_camera.global_position = future_lena.global_position
