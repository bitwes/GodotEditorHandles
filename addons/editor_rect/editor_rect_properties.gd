@tool
extends Resource
class_name EditorRectProperties

@export var size := Vector2(100, 100)
@export var moveable := false :
	set(val):
		moveable = val
		notify_property_list_changed()
@export var position := Vector2.ZERO
@export var lock_x := false :
	set(val):
		lock_x = val
		notify_property_list_changed()
@export var lock_x_value := 0
@export var lock_y := false :
	set(val):
		lock_y = val
		notify_property_list_changed()

@export var lock_y_value := 0
@export var drag_snap : Vector2 =  Vector2(1, 1)
@export_node_path var resizes : Array[NodePath] = []


func make_editor_rect(base_node : Node):
	var to_return = EditorRect.new(self)
	to_return.size = size
	for np in resizes:
		to_return.resizes.append(base_node.get_node(np))
	return to_return


func _validate_property(property: Dictionary):
	if property.name == "lock_x_value" and !lock_x:
		property.usage |= PROPERTY_USAGE_READ_ONLY

	if property.name == "lock_y_value" and !lock_y:
		property.usage |= PROPERTY_USAGE_READ_ONLY

	if property.name == "position" and !moveable:
		property.usage |= PROPERTY_USAGE_READ_ONLY
