@tool
extends Node2D
class_name EditorRect

var resizes  := []

var lock_x = false
var lock_x_value = 0
var lock_y = false
var lock_y_value = 0
var drag_snap = Vector2(1, 1)
var moveable := false
var size = Vector2(100, 100) :
	set(val):
		size = val
		if(lock_x):
			size.x = lock_x_value
		if(lock_y):
			size.y = lock_y_value
		queue_redraw()
		apply_size()
		resized.emit()
var erp : EditorRectProperties


var is_being_edited = false:
	set(val):
		is_being_edited = val
		queue_redraw()


var _move_handle_size = 30

signal resized

func _apply_to_erp():
	if(erp == null):
		return
		
	erp.size = size
	erp.position = position


func _br_has_point(point):
	var val =  Rect2(size/2 - Vector2(10, 10), Vector2(20, 20)).has_point(point)
	# print("br has ", point, " = ", val)
	return val


func _br_has_mouse():
	return _br_has_point(get_local_mouse_position())


func _editor_draw():
	if(is_being_edited):
		draw_rect(Rect2(size / -2, size), Color.WHITE, false, 1)
		var c = size / 2
		draw_circle(size/2, 10, Color.ORANGE)
		if(moveable):
			var s = Vector2(30, 30)
			draw_rect(Rect2(Vector2.ZERO - s, s * 2), Color(1, 1, 1, .5))


# This makes all children editable and assumes that this editor rect
# is a first level child and a sibling of things it edits.  You must
# make the design time root node editable.  Only the parent of a node
# can make a node have editable children.
func _make_parent_have_editable_children():
	get_parent().get_parent().set_editable_instance(get_parent(), true)


func _ready() -> void:
	if(Engine.is_editor_hint()):
		apply_size.call_deferred()
	else:
		apply_size.call_deferred()


func _draw() -> void:
	if(Engine.is_editor_hint()):
		_editor_draw()


func update_br(new_position):
	var diff = (position - new_position).abs()
	var new_size = diff * 2
	var size_diff = (size - new_size).abs()
	# print(position, "::", new_position, "::", diff)
	if(!lock_x and size_diff.x >= drag_snap.x):
		size.x = new_size.x - int(new_size.x) % int(drag_snap.x)
	if(!lock_y and size_diff.y >= drag_snap.y):
		size.y = new_size.y - int(new_size.y) % int(drag_snap.y)


func apply_size():
	if(!is_inside_tree()):
		return
	_apply_to_erp()
	for element in resizes:
		if(element is CollisionShape2D):
			apply_size_to_collision_shape(element)
		elif(element is Control):
			apply_size_to_non_centered_size_thing(element)
		else:
			push_error(self, ":  I don't know how to resize ", element)


func apply_size_to_collision_shape(coll_shape : CollisionShape2D):
	coll_shape.shape.size = size


func apply_size_to_non_centered_size_thing(thing : Variant):
	thing.position = position - (size * .5)
	thing.size = size
