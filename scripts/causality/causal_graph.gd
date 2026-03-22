class_name CausalGraph
extends Resource

## Append-only directed acyclic graph of past actions.
## Single source of truth for the game's temporal state.
## FutureState is always derived from BaseMap + CausalGraph.

signal event_added(event: CausalEvent)
signal future_delta_computed(delta: FutureDelta)

var events: Array[CausalEvent] = []
var _event_index: Dictionary = {}
var _spatial_index: Dictionary = {}

## Locked historical events that cannot be prevented.
const LOCKED_EVENTS := {
	"library_fire": {"year": 1982, "description": "Library burns down"},
	"storm": {"year": 1974, "chapter": 3, "description": "Major coastal storm"},
	"dev_company_arrives": {"year": 1985, "description": "Developer buys waterfront"},
	"mural_whitewashed": {"year": 1995, "description": "Town hall mural painted over"},
	"post_office_closes": {"year": 2003, "description": "Post office converted to café"},
}

var _propagation_rules: PropagationRules = null


## Set the propagation rules registry.
func set_propagation_rules(rules: PropagationRules) -> void:
	_propagation_rules = rules


## Add an event to the graph and propagate its consequences.
func add_event(event: CausalEvent) -> FutureDelta:
	if not _validate(event):
		return null

	events.append(event)
	_event_index[event.id] = event
	_update_spatial_index(event)

	var delta := _propagate(event)

	event_added.emit(event)
	future_delta_computed.emit(delta)
	return delta


## Validate that an event can be added.
func _validate(event: CausalEvent) -> bool:
	# Check prerequisites are satisfied
	for prereq_id in event.prerequisites:
		if not _event_index.has(prereq_id):
			return false

	# Check this doesn't conflict with locked historical events
	if _conflicts_with_locked_events(event):
		return false

	return true


## Check if an event would conflict with locked historical events.
func _conflicts_with_locked_events(_event: CausalEvent) -> bool:
	# Locked events cannot be prevented — specific checks per event type
	# Override in subclass or extend as needed
	return false


## Propagate an event to compute its 50-year consequence.
func _propagate(event: CausalEvent) -> FutureDelta:
	var rule: PropagationRule
	if _propagation_rules:
		rule = _propagation_rules.get_rule(event.type)
	else:
		rule = PropagationRule.new()
		rule.event_type = event.type

	var nearby := _get_nearby_events(event.position, 3)
	var delta := rule.apply(event, nearby)
	delta = AgingSimulation.age(delta, 50)
	return delta


## Query spatial index for events within radius grid cells.
func _get_nearby_events(pos: Vector2i, radius: int) -> Array[CausalEvent]:
	var results: Array[CausalEvent] = []
	for x in range(pos.x - radius, pos.x + radius + 1):
		for y in range(pos.y - radius, pos.y + radius + 1):
			var key := Vector2i(x, y)
			if _spatial_index.has(key):
				var cell_events: Array = _spatial_index[key]
				for e in cell_events:
					if e is CausalEvent:
						results.append(e)
	return results


## Update the spatial index with a new event.
func _update_spatial_index(event: CausalEvent) -> void:
	if not _spatial_index.has(event.position):
		_spatial_index[event.position] = []
	_spatial_index[event.position].append(event)


## Look up an event by ID.
func get_event(event_id: String) -> CausalEvent:
	return _event_index.get(event_id)


## Serialize for save files — the CausalGraph IS the save.
func serialize() -> Dictionary:
	return {"events": events.map(func(e: CausalEvent) -> Dictionary: return e.to_dict())}


## Deserialize from save data.
static func deserialize(data: Dictionary) -> CausalGraph:
	var graph := CausalGraph.new()
	for e_data in data["events"]:
		var event := CausalEvent.from_dict(e_data)
		graph.events.append(event)
		graph._event_index[event.id] = event
		graph._update_spatial_index(event)
	return graph
