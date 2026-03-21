extends Node

## Serializes and deserializes game state via the CausalGraph.
## The CausalGraph IS the save — everything else is derived from it.

const SAVE_DIR := "user://saves/"
const SAVE_EXTENSION := ".past_future"


## Save the current game state.
func save_game(slot_name: String = "autosave") -> bool:
	if not GameManager.world_state:
		return false

	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

	var save_data := {
		"version": 1,
		"causal_graph": GameManager.world_state.causal_graph.serialize(),
		"awareness": {
			"discovered_info": _serialize_info_fragments(),
			"unlocked_nodes": GameManager.awareness_manager.unlocked_nodes,
		},
		"journal": _serialize_journal(),
		"letterbox": {
			"past_to_future": GameManager.letterbox.messages_past_to_future,
			"future_to_past": GameManager.letterbox.messages_future_to_past,
			"uses_remaining": GameManager.letterbox.uses_remaining_this_chapter,
		},
	}

	var file := FileAccess.open(SAVE_DIR + slot_name + SAVE_EXTENSION, FileAccess.WRITE)
	if file == null:
		return false

	file.store_string(JSON.stringify(save_data, "\t"))
	return true


## Load a saved game state.
func load_game(slot_name: String = "autosave") -> bool:
	var path := SAVE_DIR + slot_name + SAVE_EXTENSION
	if not FileAccess.file_exists(path):
		return false

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false

	var json := JSON.new()
	var error := json.parse(file.get_as_text())
	if error != OK:
		return false

	var save_data: Dictionary = json.data

	# Restore causal graph
	GameManager.world_state.causal_graph = CausalGraph.deserialize(save_data["causal_graph"])

	return true


## Serialize info fragments for save data.
func _serialize_info_fragments() -> Array:
	var result := []
	for info in GameManager.awareness_manager.discovered_info:
		result.append({
			"id": info.id,
			"type": info.type,
			"content": info.content,
			"source_location": info.source_location,
		})
	return result


## Serialize journal entries for save data.
func _serialize_journal() -> Array:
	var result := []
	for entry in GameManager.shared_journal.entries:
		result.append({
			"text": entry.text,
			"source_era": entry.source_era,
			"auto_generated": entry.auto_generated,
			"timestamp": entry.timestamp,
		})
	return result
