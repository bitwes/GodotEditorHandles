# Adapted from https://github.com/godotengine/godot-proposals/issues/10529

var helpers = load('res://addons/editor_handles/editor_control_helpers.gd').new()
var found_all_editor_controls = false
var snap_enabled: bool = false
var snap_step : Vector2 = Vector2.ZERO
var snap_offset: Vector2 = Vector2.ZERO

var editor_controls = {
	dialog = null,
	grid_offset_x = null,
	grid_offset_y = null,
	grid_snap_x = null,
	grid_snap_y = null,
	snap_toggle = null
}


func _init():
	if(Engine.is_editor_hint()):
		setup_controls()


func setup_controls():
	var main_screen = EditorInterface.get_editor_main_screen()
	editor_controls.snap_toggle = helpers.safe_get_descendant(main_screen, ["HBoxContainer", 12], Button)

	var snap_dia_grid_container = helpers.safe_get_descendant(main_screen, ["SnapDialog", "GridContainer"], GridContainer)
	editor_controls.grid_offset_x = helpers.safe_get_child(snap_dia_grid_container, 1, SpinBox)
	editor_controls.grid_offset_y = helpers.safe_get_child(snap_dia_grid_container, 2, SpinBox)
	editor_controls.grid_snap_x = helpers.safe_get_child(snap_dia_grid_container, 4, SpinBox)
	editor_controls.grid_snap_y = helpers.safe_get_child(snap_dia_grid_container, 5, SpinBox)
	editor_controls.dialog = helpers.find_child_with_name_containing(main_screen, "SnapDialog", ConfirmationDialog)

	if(null in editor_controls.values()):
		push_error("One or more Editor Controls could not be found.")
		return
	else:
		found_all_editor_controls = true

	editor_controls.grid_offset_x.value_changed.connect(func(_val): update_values_from_editor)
	editor_controls.grid_offset_y.value_changed.connect(func(_val): update_values_from_editor)
	editor_controls.grid_snap_x.value_changed.connect(func(_val): update_values_from_editor)
	editor_controls.grid_snap_y.value_changed.connect(func(_val): update_values_from_editor)

	editor_controls.snap_toggle.toggled.connect(func(tog: bool) -> void: 
		update_values_from_editor()
		snap_enabled = tog)
	editor_controls.dialog.get_ok_button().pressed.connect(update_values_from_editor)
	update_values_from_editor()


func update_values_from_editor():
	if(!found_all_editor_controls):
		return
	snap_enabled = editor_controls.snap_toggle.button_pressed
	snap_offset.x = editor_controls.grid_offset_x.value
	snap_offset.y = editor_controls.grid_offset_y.value
	snap_step.x = editor_controls.grid_snap_x.value
	snap_step.y = editor_controls.grid_snap_y.value



func print_info():
	print("-- Snap Info --")
	print("  found all = ", found_all_editor_controls)
	print("  enabled = ", snap_enabled)
	print("  offset = ", snap_offset)
	print("  step = ", snap_step)
