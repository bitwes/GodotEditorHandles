@tool
extends Node2D

@export var editor_rect_props : EditorRectProperties

func _ready() -> void:
	add_child(editor_rect_props.make_editor_rect(self))
