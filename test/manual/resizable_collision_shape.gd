@tool
extends Node2D

@export var collision_shape_props : EditorRectProperties

func _ready() -> void:
	collision_shape_props.set_hidden_instance_properties(['lock_x', 'lock_x_value', 'lock_y', 'lock_y_value'])
	collision_shape_props.editor_setup(self)
	collision_shape_props.resized.connect(_on_editor_rect_resized)
	_on_editor_rect_resized()


func _on_editor_rect_resized():
	$Area2D/CollisionShape2D.shape.size = collision_shape_props.size
