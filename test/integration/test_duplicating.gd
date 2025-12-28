extends GutTest


class NodeWithHandles:
	extends Node
	var _engine = Engine
	@export var editor_handles : EditorHandles

	func _ready() -> void:
		if(_engine.is_editor_hint()):
			editor_handles.editor_setup(self)
			editor_handles.resized.connect(_on_editor_handles_resized)


	func _on_editor_handles_resized():
		print(self, ' resized')
		pass



func test_duplicate_gets_new_editor_handles():
	var engine_dbl = double_singleton(Engine).new()
	stub(engine_dbl, "is_editor_hint").to_return(true)

	var orig = autofree(NodeWithHandles.new())
	orig._engine = engine_dbl
	orig.editor_handles = EditorHandles.new()
	var dupe = autofree(orig.duplicate())
	dupe._engine = engine_dbl
	add_child(dupe)

	assert_ne(dupe.editor_handles, orig.editor_handles)