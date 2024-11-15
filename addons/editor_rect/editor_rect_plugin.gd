@tool
extends EditorPlugin

var plugin_name = "Editor Rect"
var editing : EditorRect
var resizing = false


func _enter_tree():
	add_custom_type(plugin_name, "Node2D", preload("editor_rect.gd"), preload("icon.svg"))


func _exit_tree():
	remove_custom_type(plugin_name)


func _handles(object: Object) -> bool:
	if(object is Node):
		return _find_editor_rect(object) != null
	else:
		return false


func _edit(object: Object) -> void:
	var new_rect = _find_editor_rect(object)
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
func _find_editor_rect(node : Node):
	if(node == null):
		return null

	if(node is EditorRect):
		return node

	var er = null
	for child in node.get_children():
		if(child is EditorRect):
			er = child
	return er


func _handle_mouse_motion(event :InputEventMouseMotion) -> bool:
	if(resizing):
		editing.update_br(editing.get_local_mouse_position())
		return true
	else:
		return false


func _handle_mouse_button(event : InputEventMouseButton):
	var input_handled = false
	if(event.button_index == MOUSE_BUTTON_LEFT):
		var undo = get_undo_redo()
		if(event.pressed):
			if(editing._br_has_mouse()):
				resizing = true
				undo.create_action("resize_editor_rect")
				undo.add_undo_property(editing, 'size', editing.size)
				input_handled = true
		elif(resizing):
			input_handled = true
			undo.add_do_property(editing, 'size', editing.size)
			undo.commit_action()
			resizing = false

	return input_handled
