extends GutTest


class NodeWithHandles:
	extends Node
	var _Engine = Engine
	@export var editor_handles : EditorHandles :
		set(val):
			editor_handles = EditorHandles.create_or_copy_resource(self, val)


func test_duplicate_gets_new_editor_handles():
	var engine_dbl = double_singleton(Engine).new()
	stub(engine_dbl, "is_editor_hint").to_return(true)

	var orig = autofree(NodeWithHandles.new())
	orig._Engine = engine_dbl
	orig.editor_handles = EditorHandles.new()
	add_child(orig)

	await wait_idle_frames(2)

	var dupe = autofree(orig.duplicate())
	dupe._Engine = engine_dbl
	add_child(dupe)

	assert_ne(dupe.editor_handles, orig.editor_handles)
	assert_not_null(dupe.editor_handles)