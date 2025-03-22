extends GutHookScript

class EngineMock:
	var is_editor_hint_value = true
	
	func is_editor_hint():
		return is_editor_hint_value


func run():
	EditorHandles._engine_global = EngineMock.new()
