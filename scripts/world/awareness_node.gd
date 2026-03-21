class_name AwarenessNode
extends Resource

## An awareness that can be unlocked for Past-Lena when
## Future-Lena discovers the required information.

@export var id: String
@export var required_info_ids: Array[String] = []
@export var unlocks_dialogue: Array[String] = []
@export var unlocks_objects: Array[String] = []
@export var narrative_text: String = ""


## Check if all required info fragments have been discovered.
func is_satisfied_by(discovered: Array[InfoFragment]) -> bool:
	for required_id in required_info_ids:
		var found := false
		for info in discovered:
			if info.id == required_id:
				found = true
				break
		if not found:
			return false
	return true
