@tool
extends Node2D

@export var editor_handles : EditorHandles


func _ready():
	editor_handles.editor_setup(self)
	editor_handles.changed.connect(apply_editor_handles)
	apply_editor_handles()


func apply_editor_handles():
	editor_handles.position = editor_handles.position.clamp(Vector2(-200, -200), Vector2(200, 200))
	editor_handles.size = editor_handles.size.clamp(Vector2(50, 50), Vector2(500, 500))
	$Sprite2D.scale = editor_handles.size / $Sprite2D.texture.get_size()
	$Sprite2D.position = editor_handles.position
