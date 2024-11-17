@tool
extends Node2D

@export var editor_rect : EditorRectProperties


func _ready():
	editor_rect.resized.connect(_on_editor_rect_resized)
	editor_rect.moved.connect(_on_editor_rect_moved)
	add_child(editor_rect.make_editor_rect(self))


func _on_editor_rect_resized():
	$Sprite2D.scale = editor_rect.size / $Sprite2D.texture.get_size()


func _on_editor_rect_moved():
	$Sprite2D.position = editor_rect.position
