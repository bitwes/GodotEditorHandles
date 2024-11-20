@tool
extends Node2D

@export var resize_properties : EditorHandles


func _ready():
	if(Engine.is_editor_hint()):
		# Example of having to override properties that have already been set
		# in instances because we didn't disable them in time.
		#resize_properties.moveable = false
		#resize_properties.position = Vector2.ZERO
		# ----
		#resize_properties.set_hidden_instance_properties(["moveable"])
		#resize_properties.set_disabled_instance_properties(["position"])
		resize_properties.editor_setup(self)
		resize_properties.changed.connect(_on_resize_properties_changed)
	_on_resize_properties_changed()


func _on_resize_properties_changed():
	resize_properties.size = resize_properties.size.max($TextureRect.texture.get_size())
	$TextureRect.size = resize_properties.size
	$TextureRect.position = resize_properties.position - $TextureRect.size / 2
