class_name LockedGarden
extends PuzzleBase

## Tutorial puzzle: The Locked Garden
##
## Steps:
## 1. Future-Lena finds a note near the garden fence (unlocks awareness)
## 2. Past-Lena plants a sapling inside the garden
## 3. Past-Lena hides the garden key under nearby rocks
## 4. Puzzle solved — the garden gate opens in both eras

const REQUIRED_TREE_TAG := "garden_tree_planted"
const REQUIRED_KEY_TAG := "garden_key_hidden"


func _ready() -> void:
	puzzle_id = "locked_garden"
	chapter = 1


## Check if the puzzle has progressed based on causal events.
func check_progress(graph: CausalGraph, awareness: AwarenessManager) -> void:
	# Check awareness: Future-Lena must have found the note
	if awareness.is_unlocked("garden_note_found"):
		progress["note_found"] = true

	# Check if tree has been planted
	for event in graph.events:
		if event.type == CausalEvent.Type.PLANT_TREE:
			if event.parameters.get("puzzle_tag") == REQUIRED_TREE_TAG:
				progress["tree_planted"] = true

		if event.type == CausalEvent.Type.HIDE_OBJECT:
			if event.parameters.get("puzzle_tag") == REQUIRED_KEY_TAG:
				progress["key_hidden"] = true

	# State transitions
	if state == State.AVAILABLE and progress.get("note_found", false):
		set_state(State.IN_PROGRESS)


## The puzzle is solved when the tree is planted and key is hidden.
func is_solved() -> bool:
	return (
		progress.get("note_found", false)
		and progress.get("tree_planted", false)
		and progress.get("key_hidden", false)
	)
