class_name PuzzleBase
extends Node

## Base class for all puzzles. Uses a state machine pattern.

enum State { LOCKED, AVAILABLE, IN_PROGRESS, SOLVED }

@export var puzzle_id: String
@export var chapter: int
@export var prerequisite_puzzles: Array[String] = []

var state: State = State.LOCKED
var progress: Dictionary = {}

signal state_changed(new_state: State)
signal puzzle_solved(puzzle_id: String)


## Transition to a new state.
func set_state(new_state: State) -> void:
	state = new_state
	state_changed.emit(new_state)
	if new_state == State.SOLVED:
		puzzle_solved.emit(puzzle_id)


## Override: define what events/conditions advance this puzzle.
func check_progress(_graph: CausalGraph, _awareness: AwarenessManager) -> void:
	pass


## Override: define the solve condition.
func is_solved() -> bool:
	return false


## Check if all prerequisite puzzles are solved.
func are_prerequisites_met(registry: PuzzleRegistry) -> bool:
	for prereq_id in prerequisite_puzzles:
		if not registry.is_puzzle_solved(prereq_id):
			return false
	return true
