class_name ConflictResolver
extends RefCounted

## Resolves conflicts when Past actions would cause problems for Future-Lena.
## Called by CausalGraph before applying any FutureDelta.

## Check if a FutureDelta would cause a conflict and resolve it.
static func resolve(delta: FutureDelta, future_lena_position: Vector2, future_lena_grid: Vector2i) -> FutureDelta:
	# If destroying a building Future-Lena is inside:
	# Future-Lena fades out, reappears at nearest safe position
	if _is_player_at_position(future_lena_grid, delta.position):
		if _is_destructive_delta(delta):
			delta.add_object_properties["displace_future_player"] = true

	return delta


## Check if the player is at or near the delta position.
static func _is_player_at_position(player_grid: Vector2i, delta_pos: Vector2i) -> bool:
	return Vector2(player_grid).distance_to(Vector2(delta_pos)) < 2.0


## Check if a delta destroys or removes something.
static func _is_destructive_delta(delta: FutureDelta) -> bool:
	return delta.remove_object_ids.size() > 0
