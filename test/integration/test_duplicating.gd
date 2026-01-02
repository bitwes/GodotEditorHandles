extends GutTest


class NodeWithHandles:
	extends Node
	var _engine = Engine
	@export var editor_handles : EditorHandles :
		set(val):
			editor_handles = EditorHandles.create_or_copy_resource(self, val)


	# func _init() -> void:
	# 	print('NEW ', self, ' ', editor_handles)
	# 	print_stack()


	func _ready() -> void:
		if(_engine.is_editor_hint()):
			# print("HERE ", self)
			# editor_handles.editor_setup(self)
			editor_handles.resized.connect(_on_editor_handles_resized)


	func _on_editor_handles_resized():
		pass
		# print(self, ' resized')




func test_duplicate_gets_new_editor_handles():
	var engine_dbl = double_singleton(Engine).new()
	stub(engine_dbl, "is_editor_hint").to_return(true)

	var orig = autofree(NodeWithHandles.new())
	orig._engine = engine_dbl
	orig.editor_handles = EditorHandles.new()
	add_child(orig)

	await wait_idle_frames(2)
	# print("------- ----------- -----------")
	var dupe = autofree(orig.duplicate())
	dupe._engine = engine_dbl
	add_child(dupe)

	assert_ne(dupe.editor_handles, orig.editor_handles)
	assert_not_null(dupe.editor_handles)