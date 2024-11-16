@tool
extends Node2D
class_name EditorRect


class SideHandle:
	var color = Color.ORANGE
	var color2 = Color.BLUE

	var active = false
	var rect = Rect2(Vector2.ZERO, Vector2(20, 20))

	func draw(draw_on):
		var c = color
		if(active):
			c = color2
		draw_on.draw_rect(rect, c)
		# draw_on.draw_circle(rect.position, rect.size.x / 2, color)


var erp : EditorRectProperties
var size = Vector2(100, 100) :
	set(val):
		size = val
		_update_for_size()

var is_being_edited = false:
	set(val):
		is_being_edited = val
		queue_redraw()
		_focused_handle = null
var resizes := []


var _move_handle_size = 30
var _side_handle_size = 20
var _move_handle = SideHandle.new()
var _handles = {
	br = SideHandle.new(),
	tl = SideHandle.new()
}
var _focused_handle = null :
	set(val):
		if(_focused_handle != null):
			_focused_handle.active = false
		_focused_handle = val
		if(_focused_handle != null):
			_focused_handle.active = true
		queue_redraw()


signal resized


func _init(edit_rect_props : EditorRectProperties):
	erp = edit_rect_props
	_move_handle.color = Color(1, 1, 1, .5)
	_move_handle.rect.size = Vector2(30, 30)
	_move_handle.rect.position = _move_handle.rect.size / -2


func _ready() -> void:
	apply_size.call_deferred()


func _draw() -> void:
	if(Engine.is_editor_hint()):
		_editor_draw()



#region Private
# --------------------
func _update_for_size():
	_update_handles()
	if(erp.lock_x):
		size.x = erp.lock_x_value
	if(erp.lock_y):
		size.y = erp.lock_y_value
	queue_redraw()
	apply_size()
	resized.emit()
	erp.size = size


func _editor_draw():
	if(is_being_edited):
		# Border
		draw_rect(Rect2(size / -2, size), Color.WHITE, false, 1)

		for key in _handles:
			_handles[key].draw(self)

		if(erp.moveable):
			_move_handle.draw(self)
			# var s = Vector2(30, 30)
			# draw_rect(Rect2(Vector2.ZERO - s, s * 2), Color(1, 1, 1, .5))


func _update_handles():
	_handles.br.rect.position = Vector2(size / 2) - _handles.br.rect.size / 2
	_handles.tl.rect.position = Vector2(size / -2) - _handles.tl.rect.size / 2


func _update_size_for_mouse_motion(new_position):
	var diff = (position - new_position).abs()
	var new_size = diff * 2
	var size_diff = (size - new_size).abs()

	if(!erp.lock_x and size_diff.x >= erp.drag_snap.x):
		size.x = new_size.x - int(new_size.x) % int(erp.drag_snap.x)
	if(!erp.lock_y and size_diff.y >= erp.drag_snap.y):
		size.y = new_size.y - int(new_size.y) % int(erp.drag_snap.y)



func _handle_move_for_mouse_motion(new_position):
	global_position = new_position
	erp.position = position
	for r in resizes:
		r.global_position = new_position


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
func set_position(new_pos):
	pass

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
	var handle = _get_first_handle_containing_point(get_local_mouse_position())
	_focused_handle = handle
	return  _focused_handle != null


func does_move_handle_contain_mouse():
	if(_move_handle.rect.has_point(get_local_mouse_position())):
		_focused_handle = _move_handle
		return true
	else:
		_focused_handle = null
		return false


func handle_mouse_motion():
	if(_focused_handle == _move_handle):
		_handle_move_for_mouse_motion(get_global_mouse_position())
	elif(_focused_handle != null):
		_update_size_for_mouse_motion(get_local_mouse_position())


func release_handles():
	_focused_handle = null
# --------------------
#endregion
