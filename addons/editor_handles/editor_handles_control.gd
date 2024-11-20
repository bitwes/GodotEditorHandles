@tool
extends Node2D
class_name EditorHandlesControl

class SideHandle:
	var color = Color.ORANGE
	var color2 = Color.BLUE

	var active = false
	# Local position.
	var rect = Rect2(Vector2.ZERO, Vector2(20, 20))

	func get_center():
		return rect.position + rect.size / 2

	func draw(draw_on):
		var c = color
		if(active):
			c = color2
		draw_on.draw_rect(rect, c)



var eh : EditorHandles
var size = Vector2(100, 100) :
	set(val):
		if(eh.lock_x):
			size.x = eh.lock_x_value
		else:
			size.x = val.x

		if(eh.lock_y):
			size.y = eh.lock_y_value
		else:
			size.y = val.y

		_update_for_size()

var is_being_edited = false:
	set(val):
		is_being_edited = val
		queue_redraw()
		_focused_handle = null


var _move_handle_size = 30
var _side_handle_size = 20
var _move_handle = SideHandle.new()
var _handles = {
	tl = SideHandle.new(),
	ct = SideHandle.new(),
	tr = SideHandle.new(),
	cr = SideHandle.new(),
	br = SideHandle.new(),
	cb = SideHandle.new(),
	bl = SideHandle.new(),
	cl = SideHandle.new()
}
var _focused_handle = null :
	set(val):
		if(_focused_handle != null):
			_focused_handle.active = false
		_focused_handle = val
		if(_focused_handle != null):
			_focused_handle.active = true
		queue_redraw()


func _init(edit_rect_props : EditorHandles):
	eh = edit_rect_props
	_init_handles()


func _init_handles():
	_move_handle.color.a = .5
	_move_handle.rect.size = Vector2(30, 30)
	_move_handle.rect.position = _move_handle.rect.size / -2


func _ready() -> void:
	position = eh.position
	_update_handles()


func _draw() -> void:
	if(Engine.is_editor_hint()):
		_editor_draw()



#region Private
# --------------------
func _update_for_size():
	_update_handles()
	queue_redraw()
	eh.size = size


func _editor_draw():
	if(is_being_edited):
		# Border
		draw_rect(Rect2(size / -2, size), Color.WHITE, false, 1)

		if(eh.resizable):
			for key in _handles:
				var hdl = _handles[key]
				hdl.draw(self)

		if(eh.moveable):
			_move_handle.draw(self)


func _update_handles():
	_handles.tl.rect.position = Vector2(size / -2)
	_handles.ct.rect.position = Vector2(0, size.y / -2)
	_handles.tr.rect.position = Vector2(size.x /2, size.y / -2)
	_handles.cr.rect.position = Vector2(size.x / 2, 0)
	_handles.br.rect.position = Vector2(size / 2)
	_handles.cb.rect.position = Vector2(0, size.y / 2)
	_handles.bl.rect.position = Vector2(size.x / -2, size.y / 2)
	_handles.cl.rect.position = Vector2(size.x / -2, 0)

	for key in _handles:
		_handles[key].rect.position -= _handles[key].rect.size / 2



func _handle_move_for_mouse_motion(new_position):
	global_position = new_position
	eh.position = position


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
## Mechanism for EditorHandles to update the global position of this contorl
## without causing recursion and allowing the manipulated
## objects to have their position changed.  This function is needed because
## this extends Node2D which has a position property that, as far as I can tell,
## cannot notify of a change without manually doing it in _process.  Checking
## in _process seems like it could introduce a race condition, this feels
## cleaner
func change_global_position(new_position):
	global_position = new_position


## change_global_position except it's for "position" instead.
func change_position(new_position):
	position = new_position


func do_handles_contain_mouse():
	if(!eh.resizable):
		return false
	var handle = _get_first_handle_containing_point(get_local_mouse_position())
	_focused_handle = handle
	return  _focused_handle != null


func does_move_handle_contain_mouse():
	if(!eh.moveable):
		return false

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
		if(eh.expand_from_center):
			resize_expand_center_drag_handle_to(_focused_handle, get_global_mouse_position())
		else:
			resize_sides_drag_handle_to(_focused_handle, get_global_mouse_position())



func release_handles():
	_focused_handle = null


func resize_expand_center_drag_handle_to(handle, new_position):
	var new_half_size = (global_position - new_position).abs()
	var new_size = new_half_size * 2
	var size_diff = (size - new_size).abs()

	if(!eh.lock_x and handle.get_center().x != 0):
		size.x = new_size.x
	if(!eh.lock_y and handle.get_center().y != 0):
		size.y = new_size.y



func resize_sides_drag_handle_to(handle, mouse_global_pos):
	var diff = mouse_global_pos - (global_position + handle.rect.position)
	size += diff * handle.get_center().sign()
	if(eh.lock_x):
		diff.x = 0
	if(eh.lock_y):
		diff.y = 0
	position += (diff / 2.0) * handle.get_center().sign().abs()
	eh.position = position


func print_info():
	print("--- ", self, " ---")
	print("  position = ", position, ' :: ', eh.position)
	print("  size = ", size, ' :: ', eh.size)
	for key in _handles:
		print("  ", key, "  l: ", _handles[key].get_center(), ' g: ', _handles[key].get_center() + position)
# --------------------
#endregion
