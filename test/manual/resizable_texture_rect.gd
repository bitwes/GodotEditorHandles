@tool
extends Node2D

@export var resize_properties : EditorRectProperties

func _ready():
	add_child(resize_properties.make_editor_rect())
	resize_properties.changed.connect(_on_resize_properties_changed)
	_on_resize_properties_changed()
	
func _on_resize_properties_changed():
	$TextureRect.size = resize_properties.size
	$TextureRect.position = resize_properties.position - $TextureRect.size / 2
