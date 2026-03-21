class_name SharedJournal
extends Node

## Both players can annotate the shared journal.
## Auto-receives entries from FutureDelta propagation and manual player notes.

signal entry_added(entry: JournalEntry)

var entries: Array[JournalEntry] = []


## Add a journal entry.
func add_entry(text: String, source_era: String, auto_generated: bool = false) -> void:
	var entry := JournalEntry.new()
	entry.text = text
	entry.source_era = source_era
	entry.auto_generated = auto_generated
	entry.timestamp = Time.get_unix_time_from_system()
	entries.append(entry)
	entry_added.emit(entry)


## Get all entries, optionally filtered by era.
func get_entries(era_filter: String = "") -> Array[JournalEntry]:
	if era_filter == "":
		return entries
	var filtered: Array[JournalEntry] = []
	for entry in entries:
		if entry.source_era == era_filter:
			filtered.append(entry)
	return filtered


## Journal entry data class.
class JournalEntry:
	var text: String
	var source_era: String
	var auto_generated: bool
	var timestamp: float
