@tool
extends Node2D

@export var resize_properties : EditorRectProperties

func _ready():
	add_child(resize_properties.make_editor_rect(self))
