extends Node

## Global game state manager. Autoloaded singleton.

signal journal_toggled(era: String, visible: bool)

var world_state: WorldState
var awareness_manager: AwarenessManager
var puzzle_registry: PuzzleRegistry
var shared_journal: SharedJournal
var letterbox: Letterbox

var past_lena: PastLena
var future_lena: FutureLena

var _journal_visible: bool = false


func _ready() -> void:
	awareness_manager = AwarenessManager.new()
	add_child(awareness_manager)

	puzzle_registry = PuzzleRegistry.new()
	add_child(puzzle_registry)

	shared_journal = SharedJournal.new()
	add_child(shared_journal)

	letterbox = Letterbox.new()
	add_child(letterbox)


## Register the world state node.
func register_world_state(ws: WorldState) -> void:
	world_state = ws
	# Connect causal graph to awareness and puzzle updates
	world_state.causal_graph.event_added.connect(_on_causal_event_added)


## Register player references.
func register_past_lena(lena: PastLena) -> void:
	past_lena = lena


## Register player references.
func register_future_lena(lena: FutureLena) -> void:
	future_lena = lena


## Toggle the shared journal overlay.
func toggle_journal(era: String) -> void:
	_journal_visible = !_journal_visible
	journal_toggled.emit(era, _journal_visible)


## Called when a new causal event is added — update puzzles.
func _on_causal_event_added(_event: CausalEvent) -> void:
	if world_state:
		puzzle_registry.update_all(world_state.causal_graph, awareness_manager)
