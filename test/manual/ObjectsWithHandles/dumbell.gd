@tool
class_name Dumbell
extends Node2D


@export var rectable : EditorHandles :
	set(val):
		print(self, ' set eh ', rectable, '->', val)
		rectable = val
@onready var center = $Center
@onready var left = $Left
@onready var right = $Right


func _init():
	print(self, '.init()')

func _ready():
	print(self, '.ready():  ', rectable)
	if(Engine.is_editor_hint()):
		rectable.editor_setup(self)
		rectable.resized.connect(_resize_for_rect.bind(rectable))
	print(self, ' dumbell conn ', get_incoming_connections())
	_resize_for_rect(rectable)


func _resize_for_rect(eh_res):
	print(self, ":  dumbell resize:  ", eh_res)
	center.scale = rectable.size / center.texture.get_size()
	center.position = rectable.position
	left.position = rectable.position - rectable.size / 2
	left.position.y = rectable.position.y
	right.position = rectable.position + rectable.size / 2
	right.position.y = rectable.position.y
