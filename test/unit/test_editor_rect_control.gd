extends GutTest

var _sender = GutInputSender.new(Input)

func before_all():
	_sender.mouse_warp = true

func after_each():
	_sender.release_all()
	_sender.clear()

func test_can_make_one():
	var erp = double(EditorRectProperties).new()
	var erc = autofree(EditorRect.new(erp))
	assert_not_null(erc)


func test_when_moveable_center_handle_contains_mouse():
	var erp = double(EditorRectProperties).new()
	var erc = add_child_autofree(EditorRect.new(erp))
	erc.position = Vector2(100, 100)
	_sender.mouse_motion(Vector2(100, 100)).wait_frames(5)
	await _sender.idle
	assert_true(erc.does_move_handle_contain_mouse())
	print(erc._move_handle.rect)


func test_when_not_moveable_center_handle_does_not_contain_mouse():
	var erp = partial_double(EditorRectProperties).new()
	var erc = add_child_autofree(EditorRect.new(erp))
	erp.moveable = false
	erc.position = Vector2(100, 100)
	_sender.mouse_motion(Vector2(100, 100)).wait_frames(5)
	await _sender.idle
	assert_false(erc.does_move_handle_contain_mouse())


