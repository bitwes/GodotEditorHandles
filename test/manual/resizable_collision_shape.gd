@tool
extends Node2D

@export var collision_shape_props : EditorHandles

func _ready() -> void:
	collision_shape_props.set_hidden_instance_properties(
			['lock_x', 'lock_x_value', 'lock_y', 
			'lock_y_value', 'moveable', 'position',
			'expand_from_center'])
	collision_shape_props.editor_setup(self)
	collision_shape_props.resized.connect(_apply_editor_handles)
	_apply_editor_handles()


func _apply_editor_handles():
	$Area2D/CollisionShape2D.shape.size = collision_shape_props.size
