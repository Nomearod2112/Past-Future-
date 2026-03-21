class_name Letterbox
extends Node

## Physical mailbox in town square. Past writes, Future reads (and vice versa).
## Limited uses per chapter to prevent trivializing puzzles.

signal message_sent(from_era: String, message: String)
signal message_received(to_era: String, message: String)

var messages_past_to_future: Array[String] = []
var messages_future_to_past: Array[String] = []
var uses_remaining_this_chapter: int = 3

const MAX_MESSAGE_LENGTH := 80


## Send a message from one era to the other.
func send_message(from_era: String, text: String) -> bool:
	if uses_remaining_this_chapter <= 0:
		return false
	if text.length() > MAX_MESSAGE_LENGTH:
		text = text.substr(0, MAX_MESSAGE_LENGTH)

	uses_remaining_this_chapter -= 1

	if from_era == "past":
		messages_past_to_future.append(text)
	else:
		messages_future_to_past.append(text)

	message_sent.emit(from_era, text)
	_deliver_with_delay(from_era, text)
	return true


## Reset uses for a new chapter.
func reset_chapter() -> void:
	uses_remaining_this_chapter = 3


## Deliver message with visual delay.
func _deliver_with_delay(from_era: String, text: String) -> void:
	var target_era := "future" if from_era == "past" else "past"
	# Short delay to sell the temporal effect
	await get_tree().create_timer(0.5).timeout
	message_received.emit(target_era, text)
