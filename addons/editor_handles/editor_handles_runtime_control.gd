extends EditorHandlesControl
class_name EditorHandlesRuntimeControl

var click_area : Area2D
var coll_shape : CollisionShape2D

func _ready():
	super()
	click_area = Area2D.new()
	# click_area.collision_layer = 0
	click_area.collision_mask = 0
	coll_shape = CollisionShape2D.new()
	coll_shape.shape = RectangleShape2D.new()
	add_child(click_area)
	click_area.add_child(coll_shape)

	eh.changed.connect(_resize_click_area)
	click_area.input_event.connect(_on_click_area_input_event)
	draw.connect(func():
		_editor_draw())


func _resize_click_area():
	coll_shape.position = eh.position
	coll_shape.shape.size = eh.size


func _unhandled_input(event: InputEvent) -> void:
	if(event is InputEventMouseButton):
		if(event.pressed):
			if(does_a_resize_handle_contain_mouse()):
				get_viewport().set_input_as_handled()
			elif(does_move_handle_contain_mouse()):
				get_viewport().set_input_as_handled()
			else:
				is_being_edited = false
		elif(_focused_handle != null):
			release_handles()
	elif(event is InputEventMouseMotion):
		if(_focused_handle != null):
			handle_mouse_motion(event)
			get_viewport().set_input_as_handled()


func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if(event is InputEventMouseButton and event.pressed):
		is_being_edited = true