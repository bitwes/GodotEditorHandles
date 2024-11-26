extends GutTest

var _sender = GutInputSender.new(Input)

func before_all():
	_sender.mouse_warp = true


func after_each():
	_sender.release_all()
	_sender.clear()


func _new_editor_handles_control(with_these_props = null, add_to = self):
	var eh = with_these_props
	if(eh == null):
		eh = EditorHandles.new()
		eh.size = Vector2(100, 100)
		eh.position = Vector2(100, 100)
	# editor_setup does the add_child
	var ehc = autofree(eh.editor_setup(add_to))
	ehc.is_being_edited = true

	# get around it not drawing when not in editor.
	ehc.draw.connect(func(): ehc._editor_draw())
	ehc.queue_redraw()

	return ehc


func test_can_make_one():
	var ehc = autofree(EditorHandlesControl.new(EditorHandles.new()))
	assert_not_null(ehc)

func test_lock_x_disables_handles():
	var ehc = _new_editor_handles_control()
	ehc.eh.lock_x = true

	for key in ['tl', 'tr', 'cr', 'br', 'bl', 'cl']:
		assert_true(ehc._handles[key].disabled, str(key, ' disabled'))


func test_lock_x_disables_handles_when_set_before_instanced():
	var eh = EditorHandles.new()
	eh.lock_x = true
	var ehc = _new_editor_handles_control(eh)

	for key in ['tl', 'tr', 'cr', 'br', 'bl', 'cl']:
		assert_true(ehc._handles[key].disabled, str(key, ' disabled'))


func test_lock_y_disables_handles():
	var ehc = _new_editor_handles_control()
	ehc.eh.lock_y = true

	for key in ['tl', 'ct', 'tr', 'br', 'cb', 'bl']:
		assert_true(ehc._handles[key].disabled, str(key, ' disabled'))


func test_lock_y_disables_handles_when_set_before_instanced():
	var eh = EditorHandles.new()
	eh.lock_y = true
	var ehc = _new_editor_handles_control(eh)

	for key in ['tl', 'ct', 'tr', 'br', 'cb', 'bl']:
		assert_true(ehc._handles[key].disabled, str(key, ' disabled'))


#region handle mouse detection
# --------------------
func test_when_moveable_center_handle_contains_mouse():
	var ehc = _new_editor_handles_control()
	ehc.position = Vector2(100, 100)
	ehc.eh.moveable = true
	_sender.mouse_motion(Vector2(100, 100)).wait_frames(5)
	await _sender.idle
	assert_true(ehc.does_move_handle_contain_mouse())



func test_when_not_moveable_center_handle_does_not_contain_mouse():
	var ehc = _new_editor_handles_control()
	ehc.eh.moveable = false
	ehc.position = Vector2(100, 100)
	_sender.mouse_motion(Vector2(100, 100)).wait_frames(5)
	await _sender.idle
	assert_false(ehc.does_move_handle_contain_mouse())


func test_when_resizable_side_handles_contain_mouse():
	var ehc = _new_editor_handles_control()
	ehc.is_being_edited = true

	ehc.eh.size = Vector2(100, 100)
	ehc.position = Vector2(100, 100)
	ehc.eh.resizable = true
	ehc.queue_redraw()

	_sender.mouse_motion(Vector2(50, 50)).wait_frames(5)
	await _sender.idle

	assert_true(ehc.does_a_resize_handle_contain_mouse())


func test_when_not_resizable_side_handles_do_not_contain_mouse():
	var ehc = _new_editor_handles_control()
	ehc.is_being_edited = true

	ehc.eh.size = Vector2(100, 100)
	ehc.position = Vector2(100, 100)

	ehc.eh.resizable = false
	ehc.queue_redraw()

	_sender.mouse_motion(Vector2(50, 50)).wait_frames(5)
	await _sender.idle

	assert_false(ehc.does_a_resize_handle_contain_mouse())

func test_when_handle_disabled_handle_does_not_contain_mouse():
	var ehc = _new_editor_handles_control()
	ehc.is_being_edited = true

	ehc.eh.size = Vector2(100, 100)
	ehc.position = Vector2(100, 100)

	ehc._handles.tl.disabled = true
	ehc.queue_redraw()

	# tl
	_sender.mouse_motion(Vector2(50, 50)).wait_frames(5)
	await _sender.idle

	assert_false(ehc.does_a_resize_handle_contain_mouse())

# --------------------
#endregion
#region Resize edges
# --------------------

var _resize_size_drag_params = ParameterFactory.named_parameters(
	['handle_key', 'move_by', 'new_size', 'new_position'],[
	['tl', Vector2(-4, -4), Vector2(104, 104), Vector2(198, 198)],
	['tl', Vector2(4, 4), Vector2(96, 96), Vector2(202, 202)],
	['br',Vector2(4, 4), Vector2(104, 104), Vector2(202, 202)],
	['cr', Vector2(4, 4), Vector2(104, 100), Vector2(202, 200)],
	['bl', Vector2(-4, 4), Vector2(104, 104), Vector2(198, 202)],
	['cb', Vector2(-4, 4), Vector2(100, 104), Vector2(200, 202)],
	['cb', Vector2(200, -20), Vector2(100, 80), Vector2(200, 190)],
	['tr', Vector2(4, -4), Vector2(104, 104), Vector2(202, 198)],
	['tr', Vector2(-4, 4), Vector2(96, 96), Vector2(198, 202)]
])
func test_resize_sides_basic(p = use_parameters(_resize_size_drag_params)):
	var eh = EditorHandles.new()
	eh.position = Vector2(200, 200)
	eh.size = Vector2(100, 100)
	eh.expand_from_center = false
	eh.moveable = true
	var ehc = _new_editor_handles_control(eh)

	ehc.drag_handle_drag_side(ehc._handles[p.handle_key], p.move_by)
	assert_eq(ehc.size, p.new_size, 'size')
	assert_eq(ehc.position, p.new_position, 'position')
	assert_eq(ehc.eh.position, ehc.position, 'upstream updated')

func test_resize_sides_lock_x(p = use_parameters(_resize_size_drag_params)):
	var eh = EditorHandles.new()
	eh.position = Vector2(200, 200)
	eh.size = Vector2(100, 100)
	eh.expand_from_center = false
	eh.moveable = true
	eh.lock_x = true
	eh.lock_x_value = 60
	var ehc = _new_editor_handles_control(eh)

	var check_size = Vector2(eh.lock_x_value, p.new_size.y)
	var check_pos = Vector2(eh.position.x, p.new_position.y)

	ehc.drag_handle_drag_side(ehc._handles[p.handle_key], p.move_by)
	assert_eq(ehc.size, check_size, 'size')
	assert_eq(ehc.position, check_pos, 'position')
	assert_eq(ehc.eh.position, ehc.position, 'upstream updated')


func test_resize_sides_lock_y(p = use_parameters(_resize_size_drag_params)):
	var eh = EditorHandles.new()
	eh.position = Vector2(200, 200)
	eh.size = Vector2(100, 100)
	eh.expand_from_center = false
	eh.moveable = true
	eh.lock_y = true
	eh.lock_y_value = 60
	var ehc = _new_editor_handles_control(eh)

	var check_size = Vector2(p.new_size.x, eh.lock_y_value)
	var check_pos = Vector2(p.new_position.x, eh.position.y)

	ehc.drag_handle_drag_side(ehc._handles[p.handle_key], p.move_by)
	assert_eq(ehc.size, check_size, 'size')
	assert_eq(ehc.position, check_pos, 'position')
	assert_eq(ehc.eh.position, ehc.position, 'upstream updated')


var _resize_size_rotated_drag_params = ParameterFactory.named_parameters(
	['handle_key', 'rotation', 'move_by', 'new_size', 'new_position', 'pause'],[
	['tl', 90, Vector2(20, -20), Vector2(120, 120), Vector2(210, 190), true],
	['br', 90, Vector2(-20, 20), Vector2(120, 120), Vector2(190, 210), true],
	['cb', 90, Vector2(-20, 0), Vector2(100, 120), Vector2(200, 210), false]


	# ['tl', 0, Vector2(4, 4), Vector2(96, 96), Vector2(202, 202)],
	# ['cr', 0, Vector2(4, 4), Vector2(104, 100), Vector2(202, 200)],
	# ['bl', 0, Vector2(-4, 4), Vector2(104, 104), Vector2(198, 202)],
	# ['cb', 0, Vector2(-4, 4), Vector2(100, 104), Vector2(200, 202)],
	# ['cb', 0, Vector2(200, -20), Vector2(100, 80), Vector2(200, 190)],
	# ['tr', 0, Vector2(4, -4), Vector2(104, 104), Vector2(202, 198)],
	# ['tr', 0, Vector2(-4, 4), Vector2(96, 96), Vector2(198, 202)]
])
func test_resize_sides_when_rotated(p = use_parameters(_resize_size_rotated_drag_params)):
	if(p.pause):
		pending("it works in editor but this looks wrong.  skipping test")
		return

	var eh = EditorHandles.new()
	eh.position = Vector2(200, 200)
	eh.size = Vector2(100, 100)
	eh.expand_from_center = false
	eh.moveable = true

	var ehc = _new_editor_handles_control(eh)
	ehc.rotation_degrees = p.rotation
	ehc._handles.ct.color_1 = Color.RED
	ehc._handles[p.handle_key].color_1 = Color.BLUE
	ehc.queue_redraw()

	if(p.pause == true):
		await wait_seconds(1)
	ehc.drag_handle_drag_side(ehc._handles[p.handle_key], p.move_by)
	if(p.pause == true):
		await wait_seconds(1)

	assert_almost_eq(ehc.size, p.new_size, Vector2(.1, .1),'size')
	assert_almost_eq(ehc.position, p.new_position, Vector2(.1, .1), 'position')
	assert_eq(ehc.eh.position, ehc.position, 'upstream updated')


# --------------------
#endregion
#region resize expand center
# --------------------

var _resize_expand_center_drag_params = ParameterFactory.named_parameters(
	['handle_key', 'move_by', 'new_size'],[
	['tl', Vector2(-1, -1), Vector2(102, 102)],
	['tl', Vector2(10, 10), Vector2(80, 80)],
	['br', Vector2(1, 1), Vector2(102, 102)],
	['br', Vector2(-20, -20), Vector2(60, 60)],
	['cr', Vector2(10, 10), Vector2(120, 100)],
	['cb', Vector2(10, 10), Vector2(100, 120)]
])
func test_resize_expand_center(p = use_parameters(_resize_expand_center_drag_params)):
	var eh = EditorHandles.new()
	eh.position = Vector2(200, 200)
	eh.size = Vector2(100, 100)
	eh.expand_from_center = true
	eh.moveable = false
	var ehc = _new_editor_handles_control(eh)

	ehc.drag_handle_expand_center(ehc._handles[p.handle_key], p.move_by)
	assert_eq(ehc.size, p.new_size, 'size')


func test_resize_expand_center_lock_width(p = use_parameters(_resize_expand_center_drag_params)):
	var eh = EditorHandles.new()
	eh.position = Vector2(200, 200)
	eh.size = Vector2(100, 100)
	eh.expand_from_center = true
	eh.moveable = false
	eh.lock_x = true
	eh.lock_x_value = 50
	var ehc = _new_editor_handles_control(eh)

	# Override expected x, since x is locked.
	var check_size = Vector2(eh.lock_x_value, p.new_size.y)


	ehc.drag_handle_expand_center(ehc._handles[p.handle_key], p.move_by)
	assert_eq(ehc.size, check_size, 'size')


func test_resize_expand_center_lock_height(p = use_parameters(_resize_expand_center_drag_params)):
	var eh = EditorHandles.new()
	eh.position = Vector2(200, 200)
	eh.size = Vector2(100, 100)
	eh.expand_from_center = true
	eh.moveable = false
	eh.lock_y = true
	eh.lock_y_value = 50
	var ehc = _new_editor_handles_control(eh)

	# Override expected y, since y is locked.
	var check_size = Vector2(p.new_size.x, eh.lock_y_value)

	ehc.drag_handle_expand_center(ehc._handles[p.handle_key], p.move_by)
	assert_eq(ehc.size, check_size, 'size')

var _resize_expand_center_scaled_drag_params = ParameterFactory.named_parameters(
	['handle_key', 'scale',         'move_by',         'new_size'],[
	['tl',          Vector2(2, 2),  Vector2(-10, -10),   Vector2(60, 60)],
	['br',          Vector2(2, 2),  Vector2(10, 10),   Vector2(60, 60)],
	# ['tl', Vector2(10, 10), Vector2(80, 80)],
	# ['br', Vector2(1, 1), Vector2(102, 102)],
	# ['br', Vector2(-20, -20), Vector2(60, 60)],
	# ['cr', Vector2(10, 10), Vector2(120, 100)],
	# ['cb', Vector2(10, 10), Vector2(100, 120)]
])
func test_resize_expand_center_scaled(p = use_parameters(_resize_expand_center_scaled_drag_params)):
	var eh = EditorHandles.new()
	eh.position = Vector2(200, 200)
	eh.size = Vector2(50, 50)
	eh.expand_from_center = true
	eh.moveable = false
	var ehc = _new_editor_handles_control(eh)
	ehc.scale = p.scale

	ehc.drag_handle_expand_center(ehc._handles[p.handle_key], p.move_by)
	assert_eq(ehc.size, p.new_size, 'size')


var _resize_expand_center_rotated_drag_params = ParameterFactory.named_parameters(
	['handle_key', 'rotation', 'move_by', 'new_size', 'pause'],[
	['tl', 90, Vector2(20, -20), Vector2(140, 140)],
	['br', 90, Vector2(-20, 20), Vector2(140, 140)],
	['cb', 90, Vector2(-20, 0), Vector2(100, 140)]
])
func test_resize_expand_center_rotated(p = use_parameters(_resize_expand_center_rotated_drag_params)):
	var eh = EditorHandles.new()
	eh.position = Vector2(200, 200)
	eh.size = Vector2(100, 100)
	eh.expand_from_center = true
	eh.moveable = true

	var ehc = _new_editor_handles_control(eh)
	ehc.rotation_degrees = p.rotation
	ehc._handles.ct.color_1 = Color.RED
	ehc._handles[p.handle_key].color_1 = Color.BLUE
	ehc.queue_redraw()

	if(p.pause == true):
		await wait_seconds(1)
	ehc.drag_handle_expand_center(ehc._handles[p.handle_key], p.move_by)
	if(p.pause == true):
		await wait_seconds(1)
	assert_almost_eq(ehc.size, p.new_size, Vector2(.1, .1),'size')
	assert_eq(ehc.eh.position, ehc.position, 'upstream updated')

# --------------------
#endregion
