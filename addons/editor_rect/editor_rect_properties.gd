@tool
extends Resource
class_name EditorRectProperties

@export var size := Vector2(100, 100)
@export var position := Vector2.ZERO
@export var lock_x := false
@export var lock_x_value := 0
@export var lock_y := false
@export var lock_y_value := 0
@export var moveable := false
@export_node_path var resizes : Array[NodePath] = []


func make_editor_rect(base_node : Node):
	var to_return = EditorRect.new()
	to_return.size = size
	for np in resizes:
		to_return.resizes.append(base_node.get_node(np))
	to_return.position = position
	to_return.lock_x = lock_x
	to_return.lock_x_value = lock_x_value
	to_return.lock_y = lock_y
	to_return.lock_y_value = lock_y_value
	to_return.moveable = moveable
	to_return.erp = self
	return to_return
