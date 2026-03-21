class_name AwarenessManager
extends Node

## Tracks what Future-Lena has discovered and what Past-Lena now "knows."
## When Future-Lena discovers information, it unlocks AwarenessNodes for Past-Lena.

signal awareness_unlocked(node: AwarenessNode)

var discovered_info: Array[InfoFragment] = []
var unlocked_nodes: Array[String] = []
var _awareness_nodes: Array[AwarenessNode] = []


## Register an awareness node that can be unlocked.
func register_awareness_node(node: AwarenessNode) -> void:
	_awareness_nodes.append(node)


## Future-Lena discovers a piece of information.
func discover(info: InfoFragment) -> void:
	discovered_info.append(info)
	_check_unlocks()


## Check if any awareness nodes should be unlocked.
func _check_unlocks() -> void:
	for node in _awareness_nodes:
		if node.id in unlocked_nodes:
			continue
		if node.is_satisfied_by(discovered_info):
			unlocked_nodes.append(node.id)
			awareness_unlocked.emit(node)


## Check if a specific awareness is unlocked.
func is_unlocked(node_id: String) -> bool:
	return node_id in unlocked_nodes
