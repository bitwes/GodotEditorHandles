@tool
class_name Dumbell
extends Node2D


@export var rectable : EditorHandles :
	set(val):
		# print(self, ' set eh ', rectable, '->', val)
		rectable = EditorHandles.get_proper_editor_handles_for(self, val)
@onready var center = $Center
@onready var left = $Left
@onready var right = $Right


# func _init():
# 	print(self, '.init()')


func _ready():
	if(Engine.is_editor_hint()):
		rectable.resized.connect(_apply_editor_handles)
	_apply_editor_handles()


func _apply_editor_handles():
	center.scale = rectable.size / center.texture.get_size()
	center.position = rectable.position
	left.position = rectable.position - rectable.size / 2
	left.position.y = rectable.position.y
	right.position = rectable.position + rectable.size / 2
	right.position.y = rectable.position.y
