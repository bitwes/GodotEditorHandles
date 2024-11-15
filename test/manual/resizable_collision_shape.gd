@tool
extends Node2D

@export var editor_rect_props : EditorRectProperties


func _ready() -> void:
	var ed_rect = editor_rect_props.make_editor_rect(self)
	print(ed_rect)
	add_child(ed_rect)
