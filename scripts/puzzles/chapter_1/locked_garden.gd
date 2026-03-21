class_name LockedGarden
extends PuzzleBase

## Tutorial puzzle: The Locked Garden
##
## Future-Lena discovers a locked garden with a beautiful old tree.
## She finds a faded note mentioning someone planted the tree decades ago.
## Past-Lena must plant the tree and find the key to the garden gate.
## The key is hidden in a cache that Past-Lena creates.

const REQUIRED_TREE_EVENT := "garden_tree_planted"
const REQUIRED_KEY_EVENT := "garden_key_hidden"


func _ready() -> void:
	puzzle_id = "locked_garden"
	chapter = 1


## Check if the puzzle has progressed based on causal events.
func check_progress(graph: CausalGraph, awareness: AwarenessManager) -> void:
	# Check if tree has been planted
	for event in graph.events:
		if event.type == CausalEvent.Type.PLANT_TREE:
			if event.parameters.get("puzzle_tag") == REQUIRED_TREE_EVENT:
				progress["tree_planted"] = true

		if event.type == CausalEvent.Type.HIDE_OBJECT:
			if event.parameters.get("puzzle_tag") == REQUIRED_KEY_EVENT:
				progress["key_hidden"] = true

	# Check awareness: Future-Lena must have found the note
	if awareness.is_unlocked("garden_note_found"):
		progress["note_found"] = true

	# Update state
	if state == State.AVAILABLE and progress.get("note_found", false):
		set_state(State.IN_PROGRESS)


## The puzzle is solved when the tree is planted and key is hidden.
func is_solved() -> bool:
	return progress.get("tree_planted", false) and progress.get("key_hidden", false)
