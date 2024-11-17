@tool
extends Node2D

@export var collision_shape_props : EditorRectProperties

func _ready() -> void:
	add_child(collision_shape_props.create_edit_control())
	collision_shape_props.resized.connect(_on_editor_rect_resized)
	_on_editor_rect_resized()


func _on_editor_rect_resized():
	$Area2D/CollisionShape2D.shape.size = collision_shape_props.size
