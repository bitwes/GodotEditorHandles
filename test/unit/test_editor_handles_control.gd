extends GutTest

var _sender = GutInputSender.new(Input)

func before_all():
	_sender.mouse_warp = true


func after_each():
	_sender.release_all()
	_sender.clear()


func _new_editor_handles_control(with_these_props = null):
	var eh = with_these_props
	if(eh == null):
		eh = EditorHandles.new()
		eh.size = Vector2(100, 100)
		eh.position = Vector2(100, 100)
	# editor_setup does the add_child
	var ehc = autofree(eh.editor_setup(self))
	ehc.is_being_edited = true

	# get around it not drawing when not in editor.
	ehc.draw.connect(func(): ehc._editor_draw())
	ehc.queue_redraw()

	return ehc


func test_can_make_one():
	var ehc = autofree(EditorHandlesControl.new(EditorHandles.new()))
	assert_not_null(ehc)


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

	assert_true(ehc.do_handles_contain_mouse())


func test_when_not_resizable_side_handles_do_not_contain_mouse():
	var ehc = _new_editor_handles_control()
	ehc.is_being_edited = true

	ehc.eh.size = Vector2(100, 100)
	ehc.position = Vector2(100, 100)

	ehc.eh.resizable = false
	ehc.queue_redraw()

	_sender.mouse_motion(Vector2(50, 50)).wait_frames(5)
	await _sender.idle

	assert_false(ehc.do_handles_contain_mouse())



#region Resize edges
# --------------------
func _new_region_resize_control():
	var eh = EditorHandles.new()
	eh.position = Vector2(200, 200)
	eh.size = Vector2(100, 100)
	eh.expand_from_center = false
	eh.moveable = true
	var ehc = _new_editor_handles_control(eh)
	return ehc

func _drag_handle_by(ehc, handle, movement):
	var hdl_glob_pos = handle.rect.position + ehc.eh.position
	ehc.resize_sides_drag_handle_to(handle, hdl_glob_pos + movement)

func _assert_handle_drag(handle_key, p):
	var ehc = _new_region_resize_control()
	_drag_handle_by(ehc, ehc._handles[handle_key], p.move_by)
	assert_eq(ehc.size, p.new_size, 'size')
	assert_eq(ehc.position, p.new_position, 'position')
	assert_eq(ehc.eh.position, ehc.position, 'upstream updated')




var _drag_params = ParameterFactory.named_parameters(
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
func test_move_all_around(p = use_parameters(_drag_params)):
	_assert_handle_drag(p.handle_key, p)
