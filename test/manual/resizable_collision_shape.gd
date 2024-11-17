@tool
extends Node2D

@export var collision_shape_props : EditorRectProperties

func _ready() -> void:
	var editor_rect = collision_shape_props.make_editor_rect()
	add_child(editor_rect)
	collision_shape_props.resized.connect(_on_editor_rect_resized)
	_on_editor_rect_resized()


func _on_editor_rect_resized():
	$Area2D/CollisionShape2D.shape.size = collision_shape_props.size
