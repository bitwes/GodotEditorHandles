@tool
extends Node2D

@export var editor_handles : EditorHandles = EditorHandles.new()


func _ready():
	if(Engine.is_editor_hint()):
		editor_handles.changed.connect(_apply_editor_handles)
		# Example of having to override properties that have already been set
		# in instances because we didn't disable them in time.
		#resize_properties.moveable = false
		#resize_properties.position = Vector2.ZERO
		# ----
		#resize_properties.set_hidden_instance_properties(["moveable"])
		#resize_properties.set_disabled_instance_properties(["position"])
		var ctrl = editor_handles.editor_setup(self)

		#ctrl.rotation_degrees = 90
		ctrl._handles.ct.color_1 = Color.RED
	_apply_editor_handles()




func _apply_editor_handles():
	editor_handles.size = editor_handles.size.max($TextureRect.texture.get_size())
	$TextureRect.size = editor_handles.size
	$TextureRect.position = editor_handles.position - $TextureRect.size / 2



func print_prop_values(thing):
	print(thing)
	for prop in thing.get_property_list():
		print('  ', prop.name, ' = ', thing.get(prop.name))
