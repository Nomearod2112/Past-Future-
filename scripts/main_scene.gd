extends Control

## Main scene controller — loads the level into both viewports,
## shares World2D between them, and registers players with GameManager.

const HARBOR_DISTRICT := preload("res://scenes/world/harbor_district.tscn")

@onready var world_state: WorldState = $WorldState
@onready var past_viewport: SubViewport = $SplitScreen/PastViewportContainer/PastViewport
@onready var future_viewport: SubViewport = $SplitScreen/FutureViewportContainer/FutureViewport
@onready var past_camera: Camera2D = $SplitScreen/PastViewportContainer/PastViewport/PastCamera
@onready var future_camera: Camera2D = $SplitScreen/FutureViewportContainer/FutureViewport/FutureCamera
@onready var past_lena: PastLena = $SplitScreen/PastViewportContainer/PastViewport/PastLena
@onready var future_lena: FutureLena = $SplitScreen/FutureViewportContainer/FutureViewport/FutureLena


func _ready() -> void:
	# Load the harbor district level into both viewports
	var past_level := HARBOR_DISTRICT.instantiate()
	past_viewport.add_child(past_level)

	# Share the same World2D so both viewports render the same world
	future_viewport.world_2d = past_viewport.world_2d

	# Register players with GameManager (WorldState self-registers in _ready)
	GameManager.register_past_lena(past_lena)
	GameManager.register_future_lena(future_lena)


func _physics_process(_delta: float) -> void:
	# Cameras follow their respective players
	past_camera.global_position = past_lena.global_position
	future_camera.global_position = future_lena.global_position
