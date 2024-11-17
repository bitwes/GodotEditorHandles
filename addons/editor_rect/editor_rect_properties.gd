@tool
extends Resource
class_name EditorRectProperties

## It's the size.  A clever combination of width and height to represent a
## rectangular shape.
@export var size := Vector2(100, 100) :
	set(val):
		size = val
		notify_property_list_changed()
		_apply_properties_to_editor_rect()

## Whether the rect is moveable.  There will be a handle in the middle that you
## can use to drag it about.
@export var moveable := false :
	set(val):
		moveable = val
		notify_property_list_changed()

## The position of the rect, enabled only when moveable.
@export var position := Vector2.ZERO:
	set(val):
		position = val
		notify_property_list_changed()
		_apply_properties_to_editor_rect()

## Enable/disable locking the width of the rect.  Disabled when y_lock enabled.
@export var lock_x := false :
	set(val):
		lock_x = val
		if(lock_x):
			size.x = lock_x_value
			_apply_properties_to_editor_rect()
		notify_property_list_changed()

## The locked width value
@export var lock_x_value := 0 :
	set(val):
		lock_x_value = val
		if(lock_x):
			size.x = val
			_apply_properties_to_editor_rect()

## Enable/Disable locking the height of the rect.  Disabled when x_lock enabled.
@export var lock_y := false :
	set(val):
		lock_y = val
		if(lock_y):
			size.y = lock_y_value
			notify_property_list_changed()

## The locked height value
@export var lock_y_value := 0 :
	set(val):
		lock_y_value = val
		if(lock_y):
			size.y = val

## Snap resizing to this increment.
@export var drag_snap : Vector2 =  Vector2(1, 1)

# This gets set anytime there is a change in the editor.  Add an element, this
# gets set.  Set an element, this gets set.  This could be used to update the
# editor rect resizes array, and probably should.  Probably.
## Paths to nodes that this rect will resize/move.  Currently supported nodes:
## - Control
## - CollisionShape2D (with a shape that has a size property)
@export_node_path var resizes : Array[NodePath] = []

var _editor_rect : EditorRect = null

# Set properties only if different to avoid recursion.
func _apply_properties_to_editor_rect():
	if(_editor_rect != null):
		if(_editor_rect.size != size):
			_editor_rect.size = size
		if(_editor_rect.position != position):
			_editor_rect.change_position(position)


func make_editor_rect(base_node : Node):
	var to_return = EditorRect.new(self)
	to_return.position = position
	to_return.size = size
	for np in resizes:
		to_return.resizes.append(base_node.get_node(np))
	_editor_rect = to_return
	return to_return


func _validate_property(property: Dictionary):
	if property.name == "lock_x" and lock_y:
		property.usage |= PROPERTY_USAGE_READ_ONLY

	if property.name == "lock_y" and lock_x:
		property.usage |= PROPERTY_USAGE_READ_ONLY

	if property.name == "lock_x_value" and !lock_x:
		property.usage |= PROPERTY_USAGE_READ_ONLY

	if property.name == "lock_y_value" and !lock_y:
		property.usage |= PROPERTY_USAGE_READ_ONLY

	if property.name == "position" and !moveable:
		property.usage |= PROPERTY_USAGE_READ_ONLY
