class_name TreeSpot
extends TemporalObject

## Interactive tree planting spot.
## Past-Lena plants a sapling → 50 years later it's a mature tree.

@export var puzzle_tag: String = ""

var _planted: bool = false
var _past_visual: Polygon2D = null


func _ready() -> void:
	super._ready()
	_past_visual = get_node_or_null("PastVisual") as Polygon2D


func _interact_past(player: PlayerBase) -> void:
	if _planted:
		show_feedback("Already planted!")
		return

	_planted = true
	show_feedback("Planted a sapling!")

	# Change the past visual to show a small sapling
	if _past_visual:
		_past_visual.color = Color(0.3, 0.6, 0.2, 1)
		_past_visual.polygon = PackedVector2Array([
			Vector2(-4, 0), Vector2(4, 0), Vector2(3, -8),
			Vector2(6, -10), Vector2(0, -16), Vector2(-6, -10), Vector2(-3, -8)
		])

	# Create the causal event
	var params := {"sapling_type": "oak", "puzzle_tag": puzzle_tag}
	var event := CausalEvent.create(
		CausalEvent.Type.PLANT_TREE,
		grid_position,
		object_id,
		params
	)
	GameManager.world_state.causal_graph.add_event(event)

	# Add journal entry
	GameManager.shared_journal.add_entry(
		"Planted a sapling near the harbor. I wonder what it'll look like in 50 years...",
		"past"
	)


func _interact_future(_player: PlayerBase) -> void:
	if _planted:
		show_feedback("A beautiful old tree.")
		GameManager.shared_journal.add_entry(
			"This tree must have been planted decades ago. It's magnificent now.",
			"future"
		)
	else:
		show_feedback("Empty plot of land.")
