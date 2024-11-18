@tool
extends Node2D

@export var editor_rect : EditorRectProperties


func _ready():
	editor_rect.editor_setup(self)
	editor_rect.changed.connect(apply_editor_rect)
	apply_editor_rect()


func apply_editor_rect():
	editor_rect.position = editor_rect.position.clamp(Vector2(-200, -200), Vector2(200, 200))
	editor_rect.size = editor_rect.size.clamp(Vector2(50, 50), Vector2(500, 500))
	$Sprite2D.scale = editor_rect.size / $Sprite2D.texture.get_size()
	$Sprite2D.position = editor_rect.position
	
