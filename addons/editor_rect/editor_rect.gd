@tool
extends Node2D
class_name EditorRect


class SideHandle:
	var rect = Rect2(Vector2.ZERO, Vector2(20, 20))

	func draw(draw_on):
		draw_on.draw_rect(rect, Color.ORANGE)
		# draw_on.draw_circle(rect.position, rect.size.x / 2, Color.ORANGE)



var erp : EditorRectProperties
var size = Vector2(100, 100) :
	set(val):
		size = val
		_update_handles()
		if(erp.lock_x):
			size.x = erp.lock_x_value
		if(erp.lock_y):
			size.y = erp.lock_y_value
		queue_redraw()
		apply_size()
		resized.emit()
		erp.size = size
var is_being_edited = false:
	set(val):
		is_being_edited = val
		queue_redraw()
var resizes  := []


var _move_handle_size = 30
var _side_handle_size = 20
var _handles = {
	br = SideHandle.new(),
	tl = SideHandle.new()
}


signal resized


func _init(edit_rect_props : EditorRectProperties):
	erp = edit_rect_props


func _ready() -> void:
	apply_size.call_deferred()


func _draw() -> void:
	if(Engine.is_editor_hint()):
		_editor_draw()



#region Private
# --------------------
func _editor_draw():
	if(is_being_edited):
		# Border
		draw_rect(Rect2(size / -2, size), Color.WHITE, false, 1)

		for key in _handles:
			_handles[key].draw(self)

		if(erp.moveable):
			var s = Vector2(30, 30)
			draw_rect(Rect2(Vector2.ZERO - s, s * 2), Color(1, 1, 1, .5))


func _update_handles():
	_handles.br.rect.position = Vector2(size / 2) - _handles.br.rect.size / 2
	_handles.tl.rect.position = Vector2(size / -2) - _handles.tl.rect.size / 2



func _update_br(new_position):
	var diff = (position - new_position).abs()
	var new_size = diff * 2
	var size_diff = (size - new_size).abs()

	if(!erp.lock_x and size_diff.x >= erp.drag_snap.x):
		size.x = new_size.x - int(new_size.x) % int(erp.drag_snap.x)
	if(!erp.lock_y and size_diff.y >= erp.drag_snap.y):
		size.y = new_size.y - int(new_size.y) % int(erp.drag_snap.y)


func _get_first_handle_containing_point(point):
	var to_return = null
	var idx = 0
	var keys = _handles.keys()
	while(idx < keys.size() and to_return == null):
		var h = _handles[keys[idx]]
		if(h.rect.has_point(point)):
			to_return = h
		idx += 1
	return to_return
# --------------------
#endregion
#region Public
# --------------------


func apply_size():
	if(!is_inside_tree()):
		return

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


func do_handles_contain_mouse():
	return _get_first_handle_containing_point(get_local_mouse_position()) != null


func handle_mouse_motion():
	_update_br(get_local_mouse_position())
# --------------------
#endregion
