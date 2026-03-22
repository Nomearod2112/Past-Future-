class_name TreeSpot
extends TemporalObject

## Interactive tree planting spot.
## Past-Lena plants a sapling → 50 years later it's a mature tree.

@export var puzzle_tag: String = ""

var _planted: bool = false
var _past_visual: Polygon2D = null
var _past_label: Polygon2D = null
var _future_visual: Polygon2D = null
var _future_trunk: Polygon2D = null


func _ready() -> void:
	super._ready()
	_past_visual = get_node_or_null("PastVisual") as Polygon2D
	_past_label = get_node_or_null("PastLabel") as Polygon2D
	_future_visual = get_node_or_null("FutureVisual") as Polygon2D
	_future_trunk = get_node_or_null("FutureTrunk") as Polygon2D


func _interact_past(_player: PlayerBase) -> void:
	if _planted:
		show_feedback("The sapling is growing strong!")
		return

	_planted = true
	show_feedback("Planted a sapling!")

	# Change past visual: ground marker → small sapling
	if _past_visual:
		_past_visual.color = Color(0.3, 0.6, 0.2, 1)
		_past_visual.polygon = PackedVector2Array([
			Vector2(-5, 4), Vector2(5, 4), Vector2(4, -6),
			Vector2(8, -10), Vector2(0, -18), Vector2(-8, -10), Vector2(-4, -6)
		])
	if _past_label:
		_past_label.color = Color(0.45, 0.3, 0.15, 1)
		_past_label.polygon = PackedVector2Array([
			Vector2(-2, 4), Vector2(2, 4), Vector2(2, 12), Vector2(-2, 12)
		])

	# Update FUTURE visual: empty plot → massive 50-year-old tree
	if _future_visual:
		_future_visual.color = Color(0.15, 0.5, 0.2, 1)
		_future_visual.polygon = PackedVector2Array([
			Vector2(-22, 0), Vector2(22, 0), Vector2(20, -12),
			Vector2(26, -18), Vector2(15, -16), Vector2(20, -28),
			Vector2(8, -22), Vector2(0, -35),
			Vector2(-8, -22), Vector2(-20, -28),
			Vector2(-15, -16), Vector2(-26, -18), Vector2(-20, -12)
		])
	if _future_trunk:
		_future_trunk.color = Color(0.4, 0.28, 0.12, 1)
		_future_trunk.polygon = PackedVector2Array([
			Vector2(-5, 0), Vector2(5, 0), Vector2(4, 14), Vector2(-4, 14)
		])

	# Flash the divider to signal temporal change
	_signal_ripple()

	# Create the causal event
	var params := {"sapling_type": "oak", "puzzle_tag": puzzle_tag}
	var event := CausalEvent.create(
		CausalEvent.Type.PLANT_TREE,
		grid_position,
		object_id,
		params
	)
	GameManager.world_state.causal_graph.add_event(event)

	GameManager.shared_journal.add_entry(
		"Planted a sapling near the garden. I wonder what it'll look like in 50 years...",
		"past"
	)


func _interact_future(_player: PlayerBase) -> void:
	if _planted:
		show_feedback("A magnificent old oak. Someone planted this decades ago.")
		GameManager.shared_journal.add_entry(
			"This tree must have been planted decades ago. It's magnificent now.",
			"future"
		)
	else:
		show_feedback("An empty patch of soil near the garden.")


## Signal a temporal ripple via the divider.
func _signal_ripple() -> void:
	var divider := get_tree().get_first_node_in_group("temporal_divider")
	if divider and divider is ColorRect:
		var tween := divider.create_tween()
		tween.tween_property(divider, "color", Color(1, 0.85, 0.3, 1), 0.2)
		tween.tween_property(divider, "color", Color(0.941, 0.78, 0.369, 1), 0.5)
