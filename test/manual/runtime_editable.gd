@tool
extends Node2D

@export var editor_handles : EditorHandles

@onready var _text_rect = $TextureRect

var _handles_ctrl : EditorHandlesControl


func _ready():
	if(Engine.is_editor_hint()):
		_handles_ctrl = editor_handles.editor_setup(self)
	else:
		_handles_ctrl = editor_handles.runtime_setup(self)
	editor_handles.changed.connect(apply_editor_handles)
	apply_editor_handles()
	
	
func apply_editor_handles():
	editor_handles.size = editor_handles.size.max(Vector2(100, 100))
	
	_text_rect.position = editor_handles.handles.tl.position
	_text_rect.size = editor_handles.size
		
