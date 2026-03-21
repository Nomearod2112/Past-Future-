class_name FutureDelta
extends RefCounted

## The output of propagation: what changes in the future.

var position: Vector2i
var remove_object_ids: Array[String] = []
var add_object_scene: PackedScene = null
var add_object_properties: Dictionary = {}
var ripple_origin: Vector2
var journal_entry: String = ""
