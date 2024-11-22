@tool
extends Node2D
class_name EditorHandlesControl

class SideHandle:
	# Local position.
	var _rect : Rect2 = Rect2(Vector2.ZERO, Vector2(20, 20))

	var color = Color.ORANGE
	var color2 = Color.BLUE
	var disabled = false
	var active = false
	## Center of handle, not rect position.
	var position = Vector2.ZERO :
		set(val):
			position = val
			_rect.position = position - _rect.size / 2
	var size = Vector2(20, 20) :
		set(val):
			size = val
			_rect.size = val


	func has_point(point):
		return _rect.has_point(point)


	func draw(draw_on):
		if(!disabled):
			var c = color
			if(active):
				c = color2
			draw_on.draw_rect(_rect, c)



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

var _focused_handle : SideHandle = null :
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
	_move_handle.size = Vector2(30, 30)
	# _move_handle.rect.position = _move_handle.rect.size / -2


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
	_handles.tl.position = Vector2(size / -2)
	_handles.ct.position = Vector2(0, size.y / -2)
	_handles.tr.position = Vector2(size.x /2, size.y / -2)
	_handles.cr.position = Vector2(size.x / 2, 0)
	_handles.br.position = Vector2(size / 2)
	_handles.cb.position = Vector2(0, size.y / 2)
	_handles.bl.position = Vector2(size.x / -2, size.y / 2)
	_handles.cl.position = Vector2(size.x / -2, 0)

	# for key in _handles:
	# 	_handles[key].rect.position -= _handles[key].rect.size / 2


func _handle_move_for_mouse_motion(new_position):
	global_position = new_position
	eh.position = position


func _get_first_handle_containing_point(point):
	var to_return = null
	var idx = 0
	var keys = _handles.keys()
	while(idx < keys.size() and to_return == null):
		var h = _handles[keys[idx]]
		if(h.has_point(point)):
			to_return = h
		idx += 1
	if(to_return != null and to_return.disabled):
		to_return = null
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

	var adj_mouse = get_local_mouse_position().rotated(get_global_transform().get_rotation())
	if(_move_handle.has_point(adj_mouse)):
		_focused_handle = _move_handle
		return true
	else:
		_focused_handle = null
		return false


func handle_mouse_motion(event :InputEventMouseMotion):
	if(_focused_handle == _move_handle):
		_handle_move_for_mouse_motion(get_global_mouse_position())
	elif(_focused_handle != null):
		var e = event.xformed_by(get_viewport().get_global_canvas_transform().affine_inverse())
		if(eh.expand_from_center):
			drag_handle_expand_center(_focused_handle, e.relative)
		else:
			resize_sides_drag_handle_to(_focused_handle, get_global_mouse_position())


func release_handles():
	_focused_handle = null


func drag_handle_expand_center(handle, change_in_position):
	var size_diff = change_in_position * handle.position.sign() * 2
	size_diff = get_global_transform().affine_inverse().basis_xform(size_diff)
	var new_size = size + size_diff# * get_global_transform().affine_inverse().get_scale()

	if(!eh.lock_x):
		size.x = new_size.x
	if(!eh.lock_y):
		size.y = new_size.y


func resize_sides_drag_handle_to(handle, mouse_global_pos):
	var grot = get_global_transform().affine_inverse().get_rotation()
	if(grot != 0.0):
		push_error("Resizing with rotated bodies is only supported with 'expand from center' on.  I just haven't figured it out yet and it goes crazy-go-nuts.")
		return
	var diff = mouse_global_pos - (global_position + handle.position)
	size += diff * handle.position.sign()
	if(eh.lock_x):
		diff.x = 0
	if(eh.lock_y):
		diff.y = 0

	var pos_change : Vector2 = (diff / 2.0) * handle.position.sign().abs()
	position += pos_change
	eh.position = position


func print_info():
	print("--- ", self, " ---")
	print("  position = ", position, ' :: ', eh.position)
	print("  size = ", size, ' :: ', eh.size)
	for key in _handles:
		print("  ", key, "  l: ", _handles[key].position, ' g: ', _handles[key].position + position)
# --------------------
#endregion


func _translate_glob_pos(glob_pos):
	var viewport_transform_inverted = get_viewport().get_global_canvas_transform().affine_inverse()
	var viewport_position = viewport_transform_inverted.basis_xform(glob_pos)
	var global_transform_inverted = get_global_transform().affine_inverse()
	var target_position = global_transform_inverted.basis_xform(viewport_position) # pixel perfect positions
	return target_position



# This is the code from GDQuest's 2nd video.  I now have to fight this function
# and make it do what I need it to do.  There's a good chance it won't even do
# what I need it to do.  But it might.
func the_calculations(event_position):
	var viewport_transform_inverted = get_viewport().get_global_canvase_transform().affine_inverse
	var viewport_position = viewport_transform_inverted.xform(event_position)
	var global_transform_inverted = get_global_transform().affine_inverse()
	var target_position = global_transform_inverted.xform(viewport_position).round() # pixel perfect positions

	# @4:39 in 2nd video, this should be this thing's size..maybe.  He's using
	# rect_extents.offset but I don't remember what that actuallis here.
	var unknown = Vector2(1, 1)
	var target_size = (target_position - unknown).abs() * 2.0
	size = target_size