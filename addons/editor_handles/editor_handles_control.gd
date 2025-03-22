@tool
extends Node2D
class_name EditorHandlesControl

class SideHandle:
	## Center of handle, not rect position.
	var position = Vector2.ZERO :
		set(val):
			position = val
			_rect.position = position - _rect.size / 2

	var size = Vector2(20, 20) :
		set(val):
			size = val
			_rect.size = val
			_rect.position = position - _rect.size / 2
	var color_1 = Color.ORANGE
	var color_2 = Color.WHITE
	var color_selected = Color.BLUE
	var disabled = false
	var active = false

	# This will change based on editor zoom level.  To manipulate the size
	# and position of the rect use size and position.
	var _rect : Rect2 = Rect2(Vector2.ZERO, size)


	func has_point(point):
		return _rect.has_point(point)


	func draw(draw_on):
		if(!disabled):
			_rect.size = size * draw_on.get_viewport().get_global_canvas_transform().affine_inverse().get_scale() *	draw_on.get_global_transform().affine_inverse().get_scale()
			_rect.position = position - _rect.size / 2
			var c = color_1
			if(active):
				c = color_selected
			_draw_circle(draw_on, c)


	func _draw_Rect(draw_on, c):
		draw_on.draw_rect(_rect, c)


	func _draw_circle(draw_on, c):
			var r = _rect.size.x / 2
			draw_on.draw_circle(position, r, color_2)
			draw_on.draw_circle(position, r * .8, c)


var snap_settings = load('res://addons/editor_handles/snap_settings.gd').new()
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

var outline_thickness = 1.0
var outline_color = Color.ORANGE
var handle_size = Vector2(20, 20)
var handle_color_1 = Color.ORANGE
var handle_color_2 = Color.WHITE
var handle_color_selected = Color.BLUE

# Used to track drag distances over time so that snapping can be done.
var _accum_change = Vector2.ZERO
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
		_accum_change = Vector2.ZERO
		queue_redraw()


func _init(edit_rect_props : EditorHandles):
	eh = edit_rect_props
	_init_handles()


func _ready() -> void:
	position = eh.position
	_update_handles()
	snap_settings.update_values_from_editor.call_deferred()


func _draw() -> void:
	if(Engine.is_editor_hint()):
		_editor_draw()


var _lastZoom
func _process(_delta):
	if Engine.is_editor_hint() and is_inside_tree():
		var newZoom = get_viewport().get_final_transform().x.x
		if _lastZoom != newZoom:
			queue_redraw()
			_lastZoom = newZoom


#region Private
# --------------------
func _init_handle(which):
	which.color_1 = handle_color_1
	which.color_2 = handle_color_2
	which.color_selected = handle_color_selected
	which.size = handle_size


func _init_handles():
	for key in _handles:
		_init_handle(_handles[key])
	_init_handle(_move_handle)


func _update_for_size():
	_update_handles()
	queue_redraw()
	eh.size = size


func _editor_draw():
	if(is_being_edited):
		# Border
		var w = outline_thickness * get_viewport().get_final_transform().affine_inverse().x.x
		draw_rect(Rect2(size / -2, size), outline_color, false, w)

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


func does_a_resize_handle_contain_mouse():
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
		drag_move_handle(get_global_mouse_position())
	elif(_focused_handle != null):
		var e = event.xformed_by(get_viewport().get_global_canvas_transform().affine_inverse())
		if(eh.expand_from_center):
			drag_handle_expand_center(_focused_handle, e.relative)
		else:
			drag_handle_drag_side(_focused_handle, e.relative)


func release_handles():
	_focused_handle = null


func drag_move_handle(new_position):
	var change_in_position = new_position
	if(snap_settings.snap_enabled):
		change_in_position.x = snapped(change_in_position.x, snap_settings.snap_step.x)
		change_in_position.y = snapped(change_in_position.y, snap_settings.snap_step.y)

	global_position = change_in_position
	eh.position = position


func drag_handle_expand_center(handle, change_in_position):
	var adj_change = get_global_transform().affine_inverse().basis_xform(change_in_position)
	if(eh.lock_x):
		adj_change.x = 0
	if(eh.lock_y):
		adj_change.y = 0
	_accum_change += adj_change * handle.position.sign()

	var size_diff = _accum_change *  2
	if(snap_settings.snap_enabled):
		size_diff.x = snapped(size_diff.x, snap_settings.snap_step.x)
		size_diff.y = snapped(size_diff.y, snap_settings.snap_step.y)
	size += size_diff
	_accum_change -= size_diff / 2


func drag_handle_drag_side(handle, change_in_position):
	var adj_change = get_global_transform().affine_inverse().basis_xform(change_in_position)
	if(eh.lock_x):
		adj_change.x = 0
	if(eh.lock_y):
		adj_change.y = 0
	_accum_change += adj_change * handle.position.sign()

	var size_diff = _accum_change
	if(snap_settings.snap_enabled):
		size_diff.x = snapped(size_diff.x, snap_settings.snap_step.x)
		size_diff.y = snapped(size_diff.y, snap_settings.snap_step.y)

	var orig_size = size
	size += size_diff
	_accum_change -= size_diff

	# The object can override size changes (custom min/max size or whatever).
	# This means the size may not have actually changed, and if it did, it might
	# not be by the amount we tried to change it by.  Repositioning has to take
	# this into account or you can push things around when an minimum size is
	# reached.
	if(size != orig_size):
		var actual_size_change = size - orig_size
		var pos_change : Vector2 = (actual_size_change / 2.0) * handle.position.sign()
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
