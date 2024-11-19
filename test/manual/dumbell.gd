@tool
extends Node2D

@export var rectable : EditorRectProperties
@onready var center = $Center
@onready var left = $Left
@onready var right = $Right


func _ready():
	rectable.editor_setup(self)
	rectable.resized.connect(_resize_for_rect)


func _resize_for_rect():
	center.scale = rectable.size / center.texture.get_size()
	center.position = rectable.position
	left.position = rectable.position - rectable.size / 2
	left.position.y = rectable.position.y
	right.position = rectable.position + rectable.size / 2
	right.position.y = rectable.position.y
