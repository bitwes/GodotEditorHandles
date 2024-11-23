@tool
extends Node2D

@export var editor_handles : EditorHandles

@onready var _text_rect = $TextureRect
var _handles_ctrl : EditorHandlesControl

func _ready():
	_handles_ctrl = editor_handles.editor_setup(self)
	editor_handles.changed.connect(apply_editor_handles)
	_handles_ctrl.draw.connect(func():
		_handles_ctrl._editor_draw())
	apply_editor_handles()
	
	
func apply_editor_handles():
	_text_rect.position = editor_handles.handles.tl.position
	_text_rect.size = editor_handles.size


func _on_check_button_toggled(toggled_on: bool) -> void:
	_handles_ctrl.is_being_edited = toggled_on
	
func _unhandled_input(event: InputEvent) -> void:
	if(event is InputEventMouseButton):
		if(event.pressed):
			_handles_ctrl.do_handles_contain_mouse()
		else:
			_handles_ctrl.release_handles()
	if(event is InputEventMouseMotion):
		if(_handles_ctrl._focused_handle != null):
			_handles_ctrl.handle_mouse_motion(event)
			
		
