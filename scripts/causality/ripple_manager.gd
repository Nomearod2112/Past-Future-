class_name RippleManager
extends Node

## Orchestrates the visual ripple transition when the future changes.
## Listens to CausalGraph.future_delta_computed and drives the shader + effects.

signal ripple_started(delta: FutureDelta)
signal ripple_completed(delta: FutureDelta)

## Phase durations in seconds
const ANTICIPATION_DURATION := 0.3
const PROPAGATION_DURATION := 0.8
const SETTLEMENT_DURATION := 0.4
const CONFIRMATION_DURATION := 0.2
const TOTAL_DURATION := 1.7
const COMPRESSED_DURATION := 0.8

var _recent_trigger_count: int = 0
var _recent_trigger_timer: float = 0.0
var _is_playing: bool = false
var _current_delta: FutureDelta = null

@export var divider_rect: ColorRect
@export var ripple_material: ShaderMaterial


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	if _recent_trigger_timer > 0.0:
		_recent_trigger_timer -= delta
		if _recent_trigger_timer <= 0.0:
			_recent_trigger_count = 0


## Play the ripple effect for a given FutureDelta.
func play_ripple(future_delta: FutureDelta) -> void:
	if _is_playing:
		return

	_is_playing = true
	_current_delta = future_delta
	_recent_trigger_count += 1
	_recent_trigger_timer = 10.0
	set_process(true)

	ripple_started.emit(future_delta)

	var duration := TOTAL_DURATION
	if _recent_trigger_count > 3:
		duration = COMPRESSED_DURATION

	var tween := create_tween()

	# Phase 1: Anticipation
	tween.tween_callback(_phase_anticipation)
	tween.tween_interval(ANTICIPATION_DURATION * (duration / TOTAL_DURATION))

	# Phase 2: Propagation
	tween.tween_callback(_phase_propagation)
	tween.tween_method(_update_ripple_progress, 0.0, 1.0, PROPAGATION_DURATION * (duration / TOTAL_DURATION))

	# Phase 3: Settlement
	tween.tween_callback(_phase_settlement)
	tween.tween_interval(SETTLEMENT_DURATION * (duration / TOTAL_DURATION))

	# Phase 4: Confirmation
	tween.tween_callback(_phase_confirmation)
	tween.tween_interval(CONFIRMATION_DURATION * (duration / TOTAL_DURATION))

	tween.tween_callback(_ripple_finished)


func _phase_anticipation() -> void:
	# Pulse the divider gold
	if divider_rect:
		var tween := create_tween()
		tween.tween_property(divider_rect, "color", Color("#F0C75E"), 0.15)
		tween.tween_property(divider_rect, "color", Color("#F0C75E80"), 0.15)


func _phase_propagation() -> void:
	# Set ripple origin on shader
	if ripple_material and _current_delta:
		ripple_material.set_shader_parameter("ripple_origin", _current_delta.ripple_origin)


func _update_ripple_progress(progress: float) -> void:
	if ripple_material:
		ripple_material.set_shader_parameter("ripple_progress", progress)


func _phase_settlement() -> void:
	# New world state fully visible, particle effects at changed object
	pass


func _phase_confirmation() -> void:
	# Golden outline pulse on changed object, journal entry slides in
	pass


func _ripple_finished() -> void:
	_is_playing = false
	_current_delta = null
	if ripple_material:
		ripple_material.set_shader_parameter("ripple_progress", 0.0)
	ripple_completed.emit(_current_delta)
