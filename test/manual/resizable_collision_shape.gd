@tool
extends Node2D

@export var collision_shape_props : EditorRectProperties

func _ready() -> void:
	add_child(collision_shape_props.make_editor_rect(self))
