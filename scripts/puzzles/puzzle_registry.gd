class_name PuzzleRegistry
extends Node

## Tracks all puzzles and their completion status.

signal puzzle_registered(puzzle_id: String)
signal puzzle_state_changed(puzzle_id: String, new_state: PuzzleBase.State)

var _puzzles: Dictionary = {}


## Register a puzzle.
func register_puzzle(puzzle: PuzzleBase) -> void:
	_puzzles[puzzle.puzzle_id] = puzzle
	puzzle.state_changed.connect(func(new_state: PuzzleBase.State) -> void:
		puzzle_state_changed.emit(puzzle.puzzle_id, new_state)
	)
	puzzle_registered.emit(puzzle.puzzle_id)


## Check if a puzzle is solved.
func is_puzzle_solved(puzzle_id: String) -> bool:
	if _puzzles.has(puzzle_id):
		return _puzzles[puzzle_id].state == PuzzleBase.State.SOLVED
	return false


## Get a puzzle by ID.
func get_puzzle(puzzle_id: String) -> PuzzleBase:
	return _puzzles.get(puzzle_id)


## Update all puzzle states based on current causal graph and awareness.
func update_all(graph: CausalGraph, awareness: AwarenessManager) -> void:
	for puzzle_id in _puzzles:
		var puzzle: PuzzleBase = _puzzles[puzzle_id]
		if puzzle.state == PuzzleBase.State.LOCKED:
			if puzzle.are_prerequisites_met(self):
				puzzle.set_state(PuzzleBase.State.AVAILABLE)
		if puzzle.state != PuzzleBase.State.SOLVED:
			puzzle.check_progress(graph, awareness)
			if puzzle.is_solved():
				puzzle.set_state(PuzzleBase.State.SOLVED)
