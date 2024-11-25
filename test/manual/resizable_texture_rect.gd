@tool
extends Node2D

@export var resize_properties : EditorHandles


func _ready():
	if(Engine.is_editor_hint()):
		resize_properties.changed.connect(_apply_resize_properties)
		# Example of having to override properties that have already been set
		# in instances because we didn't disable them in time.
		#resize_properties.moveable = false
		#resize_properties.position = Vector2.ZERO
		# ----
		#resize_properties.set_hidden_instance_properties(["moveable"])
		#resize_properties.set_disabled_instance_properties(["position"])
		var ctrl = resize_properties.editor_setup(self)
		
		#ctrl.rotation_degrees = 90
		ctrl._handles.ct.color_1 = Color.RED
	_apply_resize_properties()
	



func _apply_resize_properties():
	resize_properties.size = resize_properties.size.max($TextureRect.texture.get_size())
	$TextureRect.size = resize_properties.size
	$TextureRect.position = resize_properties.position - $TextureRect.size / 2



func print_prop_values(thing):
	print(thing)
	for prop in thing.get_property_list():
		print('  ', prop.name, ' = ', thing.get(prop.name))


	
