class_name GardenNote
extends TemporalObject

## A faded note found by Future-Lena near the garden.
## Reading it unlocks awareness for Past-Lena.

var _read: bool = false


func _interact_past(_player: PlayerBase) -> void:
	show_feedback("Nothing here yet.")


func _interact_future(_player: PlayerBase) -> void:
	if _read:
		show_feedback("A faded note about planting a garden.")
		return

	_read = true
	show_feedback("Found a note: 'Plant the tree, hide the key...'")

	# Unlock awareness so Past-Lena knows what to do
	var fragment := InfoFragment.new()
	fragment.id = "garden_note_found"
	fragment.type = "written_note"
	fragment.content = "A faded note mentioning a tree and a hidden key for the garden"
	fragment.source_location = "garden_fence"
	GameManager.awareness_manager.discover(fragment)

	GameManager.shared_journal.add_entry(
		"Found a faded note near the garden: 'Plant the tree by the fence, hide the key under the rock.'",
		"future"
	)
