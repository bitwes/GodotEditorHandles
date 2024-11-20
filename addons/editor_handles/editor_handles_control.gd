@tool
extends Node2D
class_name EditorHandlesControl

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
	br = SideHandle.new(),
	tl = SideHandle.new(),
	cr = SideHandle.new(),
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
	_move_handle.color.a = .5
	_move_handle.rect.size = Vector2(30, 30)
	_move_handle.rect.position = _move_handle.rect.size / -2


func _ready() -> void:
	position = eh.position


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
				_handles[key].draw(self)

		if(eh.moveable):
			_move_handle.draw(self)


func _update_handles():
	_handles.br.rect.position = Vector2(size / 2) - _handles.br.rect.size / 2
	_handles.tl.rect.position = Vector2(size / -2) - _handles.tl.rect.size / 2
	_handles.cr.rect.position = Vector2(size.x / 2, 0) -_handles.cr.rect.size / 2


func _update_size_expand_from_center(new_position):
	var diff = (global_position - new_position).abs()
	var new_size = diff * 2
	var size_diff = (size - new_size).abs()

	if(!eh.lock_x and size_diff.x >= eh.drag_snap.x):
		size.x = new_size.x - int(new_size.x) % int(eh.drag_snap.x)
	if(!eh.lock_y and size_diff.y >= eh.drag_snap.y):
		size.y = new_size.y - int(new_size.y) % int(eh.drag_snap.y)

func _update_size_by_side(mouse_global_pos):
	if(_focused_handle == _handles.tl):
		var diff = _focused_handle.rect.position + global_position - mouse_global_pos
		var new_size = size + diff
		print(_focused_handle.rect, '::', mouse_global_pos, '::',diff, '::', new_size)
		size = new_size
		position -= diff / 2
		eh.position = position
	elif(_focused_handle == _handles.br):
		var diff = mouse_global_pos - global_position - _handles.br.rect.position
		var new_size = abs(size + diff)
		print(_focused_handle.rect, '::', mouse_global_pos, '::',diff, '::', new_size)
		size = new_size
		position += diff / 2
		eh.position = position
	elif(_focused_handle == _handles.cr):
		var diff = Vector2(mouse_global_pos.x - global_position.x - _handles.br.rect.position.x, 0)
		var new_size = abs(size + diff)
		print(_focused_handle.rect, '::', mouse_global_pos, '::',diff, '::', new_size)
		size = new_size
		position += diff / 2
		eh.position = position



func _update_size_for_mouse_motion(new_position):
	if(eh.expand_from_center):
		_update_size_expand_from_center(new_position)
	else:
		_update_size_by_side(new_position)

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
		_update_size_for_mouse_motion(get_global_mouse_position())


func release_handles():
	_focused_handle = null
# --------------------
#endregion
