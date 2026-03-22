class_name LetterboxObject
extends TemporalObject

## Interactive letterbox for cross-time messaging.

var _pending_message: String = ""


func _interact_past(player: PlayerBase) -> void:
	if GameManager.letterbox.uses_remaining_this_chapter <= 0:
		show_feedback("No more letters this chapter.")
		return

	# Simple message — in a full implementation this would open a UI
	var message := "Dear Future-Me: Look near the garden."
	GameManager.letterbox.send_message("past", message)
	show_feedback("Letter sent to the future!")

	GameManager.shared_journal.add_entry(
		"Sent a letter through the old letterbox. Will it still be there in 50 years?",
		"past"
	)


func _interact_future(_player: PlayerBase) -> void:
	var messages: Array = GameManager.letterbox.messages_past_to_future
	if messages.size() > 0:
		var latest: String = messages[messages.size() - 1]
		show_feedback("Letter: " + latest)
		GameManager.shared_journal.add_entry(
			"Found an old letter: \"" + latest + "\"",
			"future"
		)
	else:
		show_feedback("Letterbox is empty.")
