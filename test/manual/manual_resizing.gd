@tool
extends Node2D

@export var editor_rect : EditorRectProperties


func _ready():
	editor_rect.resized.connect(_on_editor_rect_resized)
	editor_rect.moved.connect(_on_editor_rect_moved)
	editor_rect.changed.connect(_on_editor_rect_changed)
	add_child(editor_rect.make_editor_rect())
	_on_editor_rect_changed()


func _on_editor_rect_resized():
	pass


func _on_editor_rect_moved():
	pass


func _on_editor_rect_changed():
	$Sprite2D.scale = editor_rect.size / $Sprite2D.texture.get_size()
	$Sprite2D.position = editor_rect.position
	#print("changed")
