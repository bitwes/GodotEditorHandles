extends GutTest

var _sender = GutInputSender.new(Input)

func before_all():
	_sender.mouse_warp = true


func after_each():
	_sender.release_all()
	_sender.clear()


func _new_editor_rect_control():
	var erp = EditorRectProperties.new()
	# editor_setup does the add_child
	var erc = autofree(erp.editor_setup(self))

	# Center at (100, 100), corners at (50, 50) and (150, 150)
	erc.erp.size = Vector2(100, 100)
	erc.position = Vector2(100, 100)

	# get around it not drawing when not in editor.
	erc.draw.connect(func(): erc._editor_draw())
	erc.queue_redraw()

	return erc


func test_can_make_one():
	var erc = autofree(EditorRect.new(EditorRectProperties.new()))
	assert_not_null(erc)


func test_when_moveable_center_handle_contains_mouse():
	var erc = _new_editor_rect_control()
	erc.position = Vector2(100, 100)
	erc.erp.moveable = true
	_sender.mouse_motion(Vector2(100, 100)).wait_frames(5)
	await _sender.idle
	assert_true(erc.does_move_handle_contain_mouse())



func test_when_not_moveable_center_handle_does_not_contain_mouse():
	var erc = _new_editor_rect_control()
	erc.erp.moveable = false
	erc.position = Vector2(100, 100)
	_sender.mouse_motion(Vector2(100, 100)).wait_frames(5)
	await _sender.idle
	assert_false(erc.does_move_handle_contain_mouse())


func test_when_resizable_side_handles_contain_mouse():
	var erc = _new_editor_rect_control()
	erc.erp._editor_rect = erc
	erc.is_being_edited = true
	erc.draw.connect(func(): erc._editor_draw())

	erc.erp.size = Vector2(100, 100)
	erc.position = Vector2(100, 100)
	erc.erp.resizable = true
	erc.queue_redraw()

	_sender.mouse_motion(Vector2(50, 50)).wait_frames(5)
	await _sender.idle

	assert_true(erc.do_handles_contain_mouse())


func test_when_not_resizable_side_handles_do_not_contain_mouse():
	var erc = _new_editor_rect_control()
	erc.erp._editor_rect = erc
	erc.is_being_edited = true
	erc.draw.connect(func(): erc._editor_draw())

	erc.erp.size = Vector2(100, 100)
	erc.position = Vector2(100, 100)

	erc.erp.resizable = false
	erc.queue_redraw()

	_sender.mouse_motion(Vector2(50, 50)).wait_frames(5)
	await _sender.idle

	assert_false(erc.do_handles_contain_mouse())
