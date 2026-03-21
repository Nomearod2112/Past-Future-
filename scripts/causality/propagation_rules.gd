class_name PropagationRules
extends Node

## Registry of all propagation rules. Maps event types to their rules.

var _rules: Dictionary = {}


## Register a propagation rule for an event type.
func register_rule(rule: PropagationRule) -> void:
	_rules[rule.event_type] = rule


## Get the propagation rule for an event type.
func get_rule(event_type: CausalEvent.Type) -> PropagationRule:
	if _rules.has(event_type):
		return _rules[event_type]
	# Return a default rule if none registered
	var default_rule := PropagationRule.new()
	default_rule.event_type = event_type
	return default_rule


## Load all propagation rule resources from the propagation directory.
func load_rules_from_directory(path: String = "res://resources/propagation/") -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var rule: PropagationRule = load(path + file_name)
			if rule:
				register_rule(rule)
		file_name = dir.get_next()
