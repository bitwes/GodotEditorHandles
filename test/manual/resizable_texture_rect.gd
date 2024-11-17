@tool
extends Node2D

@export var resize_properties : EditorRectProperties

func _ready():
	if(Engine.is_editor_hint()):
		add_child(resize_properties.create_edit_control())
		resize_properties.changed.connect(_on_resize_properties_changed)
	_on_resize_properties_changed()

func _on_resize_properties_changed():
	resize_properties.moveable = true
	$TextureRect.size = resize_properties.size
	$TextureRect.position = resize_properties.position - $TextureRect.size / 2
