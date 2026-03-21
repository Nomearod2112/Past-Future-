class_name CausalEvent
extends Resource

## Data class representing a single action taken in the Past era.
## Immutable once created — the CausalGraph is append-only.

enum Type {
	PLANT_TREE,
	BUILD_STRUCTURE,
	DESTROY_STRUCTURE,
	HIDE_OBJECT,
	REDIRECT_WATER,
	BEFRIEND_NPC,
	WRITE_MESSAGE,
	BLUEPRINT,
	OIL_MECHANISM,
	COMMISSION_WORK,
}

@export var id: String
@export var type: Type
@export var position: Vector2i
@export var target_object_id: String
@export var parameters: Dictionary
@export var timestamp: float
@export var prerequisites: Array[String]


## Create a new CausalEvent with a generated UUID.
static func create(event_type: Type, pos: Vector2i, target_id: String = "", params: Dictionary = {}, prereqs: Array[String] = []) -> CausalEvent:
	var event := CausalEvent.new()
	event.id = _generate_uuid()
	event.type = event_type
	event.position = pos
	event.target_object_id = target_id
	event.parameters = params
	event.timestamp = Time.get_unix_time_from_system()
	event.prerequisites = prereqs
	return event


## Serialize to dictionary for save files.
func to_dict() -> Dictionary:
	return {
		"id": id,
		"type": type,
		"position": [position.x, position.y],
		"target_object_id": target_object_id,
		"parameters": parameters,
		"timestamp": timestamp,
		"prerequisites": prerequisites,
	}


## Deserialize from dictionary.
static func from_dict(data: Dictionary) -> CausalEvent:
	var event := CausalEvent.new()
	event.id = data["id"]
	event.type = data["type"] as Type
	var pos: Array = data["position"]
	event.position = Vector2i(pos[0], pos[1])
	event.target_object_id = data.get("target_object_id", "")
	event.parameters = data.get("parameters", {})
	event.timestamp = data.get("timestamp", 0.0)
	var prereqs: Array = data.get("prerequisites", [])
	event.prerequisites.assign(prereqs)
	return event


static func _generate_uuid() -> String:
	var chars := "abcdef0123456789"
	var uuid := ""
	for i in range(32):
		if i == 8 or i == 12 or i == 16 or i == 20:
			uuid += "-"
		uuid += chars[randi() % chars.length()]
	return uuid
