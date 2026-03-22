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
var _past_x: Polygon2D = null
var _future_visual: Polygon2D = null
var _future_moss: Polygon2D = null


func _ready() -> void:
	super._ready()
	_past_visual = get_node_or_null("PastVisual") as Polygon2D
	_past_x = get_node_or_null("PastX") as Polygon2D
	_future_visual = get_node_or_null("FutureVisual") as Polygon2D
	_future_moss = get_node_or_null("FutureMoss") as Polygon2D


func _interact_past(_player: PlayerBase) -> void:
	if _item_hidden:
		show_feedback("Already hidden something here.")
		return

	_item_hidden = true
	show_feedback("Hidden the " + hidden_item_name + " in a " + container_type + "!")

	# Update past visual: rock pile → disturbed earth with X mark
	if _past_visual:
		_past_visual.color = Color(0.5, 0.4, 0.25, 1)
	if _past_x:
		_past_x.color = Color(0.9, 0.7, 0.2, 0.9)

	# Update FUTURE visual: show aged buried cache
	if _future_visual:
		_future_visual.color = Color(0.4, 0.38, 0.3, 1)
	if _future_moss:
		_future_moss.color = Color(0.25, 0.5, 0.25, 0.7)
		_future_moss.polygon = PackedVector2Array([
			Vector2(-14, -6), Vector2(0, -10), Vector2(14, -6),
			Vector2(12, 6), Vector2(-12, 6)
		])

	# Flash the divider
	_signal_ripple()

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
		show_feedback("Looks like a pile of old rocks.")
		return

	if _item_found:
		show_feedback("Already dug here. The " + hidden_item_name + " is gone.")
		return

	_item_found = true
	show_feedback("Found the " + hidden_item_name + "!")

	# Update future visual: show opened cache
	if _future_visual:
		_future_visual.color = Color(0.35, 0.3, 0.2, 1)
	if _future_moss:
		_future_moss.visible = false

	# Unlock awareness
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


## Signal a temporal ripple via the divider.
func _signal_ripple() -> void:
	var divider := get_tree().get_first_node_in_group("temporal_divider")
	if divider and divider is ColorRect:
		var tween := divider.create_tween()
		tween.tween_property(divider, "color", Color(1, 0.85, 0.3, 1), 0.2)
		tween.tween_property(divider, "color", Color(0.941, 0.78, 0.369, 1), 0.5)
