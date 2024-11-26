@tool
extends EditorPlugin

var plugin_name = "EditorHandles"
var editing : EditorHandlesControl
var resizing = false
var moving = false


func _enter_tree():
	add_custom_type(plugin_name, "Resource", preload("editor_handles.gd"), preload("icon.svg"))



func _exit_tree():
	remove_custom_type(plugin_name)


func _handles(object: Object) -> bool:
	if(object is Node):
		return _find_editor_handles_control(object) != null
	else:
		return false


func _edit(object: Object) -> void:
	var new_rect = _find_editor_handles_control(object)
	if(new_rect != editing):
		if(editing != null):
			editing.is_being_edited = false
		if(new_rect != null):
			new_rect.is_being_edited = true
		editing = new_rect


func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if(editing == null or not editing.visible):
		return false

	if(event is InputEventMouseButton):
		return _handle_mouse_button(event)

	if(event is InputEventMouseMotion):
		return _handle_mouse_motion(event)

	return false


# ------------------------
# Private
# ------------------------
func _find_editor_handles_control(node : Node):
	if(node == null):
		return null

	# I don't tihnk this could ever happen with how things are now.
	if(node is EditorHandlesControl):
		return node

	var er = null
	for child in node.get_children():
		if(child is EditorHandlesControl):
			er = child
	return er


func _handle_mouse_motion(event :InputEventMouseMotion) -> bool:
	if(resizing or moving):
		editing.handle_mouse_motion(event)
		return true
	else:
		return false


func _handle_mouse_button(event : InputEventMouseButton):
	var input_handled = false
	if(event.button_index == MOUSE_BUTTON_LEFT):
		var undo = get_undo_redo()
		if(event.pressed):
			if(editing.do_handles_contain_mouse()):
				resizing = true
				undo.create_action(&"resize_editor_handles")
				undo.add_undo_property(editing.eh, &"position", editing.position)
				undo.add_undo_property(editing.eh, &'size', editing.size)
				input_handled = true
			elif(editing.does_move_handle_contain_mouse()):
				moving = true
				undo.create_action(&"move_editor_handles")
				undo.add_undo_property(editing.eh, &"position", editing.position)
				input_handled = true
		elif(resizing):
			input_handled = true
			undo.add_do_property(editing.eh, &'size', editing.size)
			undo.add_do_property(editing.eh, &'position', editing.position)
			undo.commit_action()
			resizing = false
			editing.release_handles()
		elif(moving):
			input_handled = true
			undo.add_do_property(editing.eh, &'position', editing.position)
			undo.commit_action()
			moving = false
			editing.release_handles()

	return input_handled
