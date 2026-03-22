class_name HidingSpot
extends TemporalObject

## Interactive hiding spot for cross-time item transfer.
## Past-Lena hides an item → Future-Lena can dig it up 50 years later.

@export var puzzle_tag: String = ""
@export var container_type: String = "metal_box"
@export var hidden_item_name: String = "item"

var _item_hidden: bool = false
var _item_found: bool = false
var _past_visual: Polygon2D = null
var _future_visual: Polygon2D = null


func _ready() -> void:
	super._ready()
	_past_visual = get_node_or_null("PastVisual") as Polygon2D
	_future_visual = get_node_or_null("FutureVisual") as Polygon2D


func _interact_past(player: PlayerBase) -> void:
	if _item_hidden:
		show_feedback("Already hidden something here.")
		return

	_item_hidden = true
	show_feedback("Hidden " + hidden_item_name + " in " + container_type + "!")

	# Update visual to show disturbed ground
	if _past_visual:
		_past_visual.color = Color(0.5, 0.4, 0.25, 1)

	# Create the causal event
	var params := {
		"container_type": container_type,
		"hidden_item": hidden_item_name,
		"puzzle_tag": puzzle_tag,
	}
	var event := CausalEvent.create(
		CausalEvent.Type.HIDE_OBJECT,
		grid_position,
		object_id,
		params
	)
	GameManager.world_state.causal_graph.add_event(event)

	GameManager.shared_journal.add_entry(
		"Buried the " + hidden_item_name + " in a " + container_type + ". Hope it survives 50 years.",
		"past"
	)


func _interact_future(_player: PlayerBase) -> void:
	if not _item_hidden:
		show_feedback("Just some old rocks.")
		return

	if _item_found:
		show_feedback("Already searched here.")
		return

	_item_found = true
	show_feedback("Found the " + hidden_item_name + "!")

	# Update visual
	if _future_visual:
		_future_visual.color = Color(0.4, 0.35, 0.25, 1)

	# Unlock awareness for the past
	var fragment := InfoFragment.new()
	fragment.id = puzzle_tag + "_found"
	fragment.type = "discovery"
	fragment.content = "Found " + hidden_item_name + " hidden long ago"
	fragment.source_location = "hiding_spot"
	GameManager.awareness_manager.discover(fragment)

	GameManager.shared_journal.add_entry(
		"Dug up an old " + container_type + " — the " + hidden_item_name + " was inside!",
		"future"
	)
