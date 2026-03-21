class_name EnvSignal
extends Node

## Environmental signals: Past-Lena arranges objects, Future-Lena sees aged results.
## Future-Lena marks surfaces, Past-Lena sees "mysterious marks."
## These are lightweight CausalEvents of type WRITE_MESSAGE with visual-only propagation.

signal signal_placed(era: String, position: Vector2i, data: Dictionary)


## Place an environmental signal (stone pattern, mark, arrangement).
func place_signal(era: String, pos: Vector2i, signal_data: Dictionary) -> void:
	signal_placed.emit(era, pos, signal_data)
