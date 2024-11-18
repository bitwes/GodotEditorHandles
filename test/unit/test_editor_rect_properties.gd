extends GutTest

var dyn_script = load("res://addons/gut/dynamic_gdscript.gd").new()



# I made this because using `set` on a resource (just a resource?) does not go
# through the setter and I wanted to make a parameterized test.
func set_property_with_code(thing, prop_name, value):
	var code = str("\n
	func _init(thing, value):\n
		thing.", prop_name, " = value")
	dyn_script.create_script_from_source(code).new(thing, value)


func assert_bit_flag_set(value, flag, msg=''):
	var anded = value & flag
	var display = str("Expected ", flag, " to be set in ", value, ' ', msg)
	if(anded == 0):
		fail_test(display)
	else:
		pass_test(display)


func assert_bit_flag_not_set(value, flag, msg=''):
	var anded = value & flag
	var display = str("Expected ", flag, " to not be set in ", value, ' ', msg)
	if(anded == 0):
		pass_test(display)
	else:
		fail_test(display)


func find_property(prop_name, prop_list):
	var idx = 0
	var to_return = {}
	while(idx < prop_list.size() and to_return.is_empty()):
		if(prop_list[idx].name == prop_name):
			to_return = prop_list[idx]
		idx += 1
	return to_return


func assert_property_usage_bit_flag_set(object, property_name, flag):
	var props = object.get_property_list()
	var prop = find_property(property_name, props)
	assert_bit_flag_set(prop.usage, flag, str(' for ', property_name, ' on ', object))


func assert_property_usage_bit_flag_not_set(object, property_name, flag):
	var props = object.get_property_list()
	var prop = find_property(property_name, props)
	assert_bit_flag_not_set(prop.usage, flag, str(' for ', property_name, ' on ', object))



# -----------------------------
# Setup/Teardown
# -----------------------------
func before_all():
	dyn_script.default_script_name_no_extension = "test_editor_rect_properties"




# -----------------------------
# Begin Tests
# -----------------------------
func test_can_make_one():
	var erp = EditorRectProperties.new()
	assert_not_null(erp)


func test_new_erp_is_local_to_scene():
	var erp = EditorRectProperties.new()
	assert_true(erp.resource_local_to_scene)


var _changed_emit_props = [
	['size', Vector2(3, 4)],
	['moveable', true],
	['position', Vector2(1, 2)],
	['lock_x', true],
	['lock_x_value', 99],
	['lock_y', true],
	['lock_y_value', 99],
	['resizable', false]
]
func test_properties_emit_changed_signal(p = use_parameters(_changed_emit_props)):
	var erp = EditorRectProperties.new()
	watch_signals(erp)
	set_property_with_code(erp, p[0], p[1])
	assert_signal_emitted(erp, "changed", ' for ' + p[0])
	assert_signal_emitted(erp, 'property_list_changed', ' for ' + p[0])


func test_default_values():
	var erp = EditorRectProperties.new()
	assert_true(erp.resizable, 'resizable')
	assert_false(erp.moveable, 'moveable')
	assert_false(erp.lock_x, 'lock_x')
	assert_false(erp.lock_y, 'lock_y')
	assert_eq(erp.lock_x_value, 0, 'lock_x_value')
	assert_eq(erp.lock_y_value, 0, 'lock_y_value')



#region Property enable/disable
# --------------------
func test_default_disabled_properties(p = use_parameters([
				"lock_x_value",	"lock_y_value", "position"])):
	var erp = EditorRectProperties.new()
	var prop_props = find_property(p, erp.get_property_list())
	assert_false(prop_props.is_empty(), str('prop ', p, ' was found'))
	assert_bit_flag_set(prop_props.usage, PROPERTY_USAGE_READ_ONLY, str(' on ', p))


func test_unsetting_resizable_disables_size_related_props():
	var erp = EditorRectProperties.new()
	erp.resizable = false
	assert_property_usage_bit_flag_set(erp, 'size', PROPERTY_USAGE_READ_ONLY)
	assert_property_usage_bit_flag_set(erp, 'lock_x', PROPERTY_USAGE_READ_ONLY)
	assert_property_usage_bit_flag_set(erp, 'lock_y', PROPERTY_USAGE_READ_ONLY)
	assert_property_usage_bit_flag_not_set(erp, 'resizable', PROPERTY_USAGE_READ_ONLY)


func test_when_resizable_unchecked_and_locks_enabled_lock_values_are_disabled():
	var erp = EditorRectProperties.new()
	erp.lock_x = true
	erp.lock_y = true
	erp.resizable = false
	assert_property_usage_bit_flag_set(erp, 'lock_x_value', PROPERTY_USAGE_READ_ONLY)
	assert_property_usage_bit_flag_set(erp, 'lock_y_value', PROPERTY_USAGE_READ_ONLY)



func test_setting_lock_x_enables_lock_x_value():
	var erp = EditorRectProperties.new()
	erp.lock_x = true
	var prop_props = find_property("lock_x_value", erp.get_property_list())
	assert_bit_flag_not_set(prop_props.usage, PROPERTY_USAGE_READ_ONLY)


func test_setting_lock_x_disables_lock_y():
	var erp = EditorRectProperties.new()
	erp.lock_x = true
	var prop_props = find_property("lock_y", erp.get_property_list())
	assert_bit_flag_set(prop_props.usage, PROPERTY_USAGE_READ_ONLY)


func test_setting_lock_y_enables_lock_y_value():
	var erp = EditorRectProperties.new()
	erp.lock_y = true
	var prop_props = find_property("lock_y_value", erp.get_property_list())
	assert_bit_flag_not_set(prop_props.usage, PROPERTY_USAGE_READ_ONLY)


func test_setting_lock_y_disables_lock_x():
	var erp = EditorRectProperties.new()
	erp.lock_y = true
	var prop_props = find_property("lock_x", erp.get_property_list())
	assert_bit_flag_set(prop_props.usage, PROPERTY_USAGE_READ_ONLY)


func test_setting_moveable_enables_position():
	var erp = EditorRectProperties.new()
	erp.moveable = true
	var prop_props = find_property("position", erp.get_property_list())
	assert_bit_flag_not_set(prop_props.usage, PROPERTY_USAGE_READ_ONLY)

# --------------------
#endregion
#region Signal
# --------------------
func test_setting_size_in_signal_handler_does_not_cause_recursion():
	var erp = EditorRectProperties.new()
	erp.changed.connect(func(): erp.size.x += 1)
	erp.size.x = 50
	assert_eq(erp.size.x, 51.0)


func test_setting_position_in_signal_handler_does_not_cause_recursion():
	var erp = EditorRectProperties.new()
	erp.changed.connect(func(): erp.position.y += 1)
	erp.position.y = 50
	assert_eq(erp.position.y, 51.0)


func test_setting_position_and_size_in_handler_is_fine():
	var erp = EditorRectProperties.new()
	erp.changed.connect(func():
		erp.position.y += 1
		erp.size.x += 1)
	erp.position.y = 50
	erp.size.x = 50
	# size is set second, so it will be set to 50 then incremented
	assert_eq(erp.size.x, 51.0, 'size')
	# position is set first, so it will get incremented twice
	assert_eq(erp.position.y, 52.0, 'position')


func test_setting_moveable_in_handler_does_not_cause_recursion():
	var erp = EditorRectProperties.new()
	erp.changed.connect(func(): erp.moveable = true)
	erp.moveable = false
	assert_true(erp.moveable)

func test_setting_lock_x_in_handler_does_not_cause_recursion():
	var erp = EditorRectProperties.new()
	erp.changed.connect(func(): erp.lock_x = true)
	erp.lock_x = false
	assert_true(erp.lock_x)

func test_setting_lock_x_value_in_handler_does_not_cause_recursion():
	var erp = EditorRectProperties.new()
	erp.changed.connect(func(): erp.lock_x_value = 99)
	erp.lock_x_value = 50
	assert_eq(erp.lock_x_value, 99)


func test_setting_lock_y_in_handler_does_not_cause_recursion():
	var erp = EditorRectProperties.new()
	erp.changed.connect(func(): erp.lock_y = true)
	erp.lock_y = false
	assert_true(erp.lock_y)

func test_setting_lock_y_value_in_handler_does_not_cause_recursion():
	var erp = EditorRectProperties.new()
	erp.changed.connect(func(): erp.lock_y_value = 99)
	erp.lock_y_value = 50
	assert_eq(erp.lock_y_value, 99)
# --------------------
#endregion
#region Hidden/disabled properties
# --------------------
func test_setting_hidden_props_signals_list_changed():
	var erp = EditorRectProperties.new()
	watch_signals(erp)
	erp.set_hidden_instance_properties(['asdf'])
	assert_signal_emitted(erp, 'property_list_changed')


func test_hidden_properties_are_visible_when_not_editing_an_instance():
	var erp = EditorRectProperties.new()
	erp.set_hidden_instance_properties(['lock_y'])
	assert_property_usage_bit_flag_set(erp, 'lock_y', PROPERTY_USAGE_EDITOR)


func test_hidden_properties_are_not_visible_when_editing_an_instance():
	var erp = EditorRectProperties.new()
	erp._is_instance = true
	erp.set_hidden_instance_properties(['lock_y'])
	assert_property_usage_bit_flag_not_set(erp, 'lock_y', PROPERTY_USAGE_EDITOR)


func test_setting_disabled_props_signals_list_changed():
	var erp := EditorRectProperties.new()
	watch_signals(erp)
	erp.set_disabled_instance_properties(['asdf'])
	assert_signal_emitted(erp, 'property_list_changed')


func test_disabled_properties_are_enabled_when_not_editing_an_instance():
	var erp = EditorRectProperties.new()
	erp.set_disabled_instance_properties(['lock_x'])
	assert_property_usage_bit_flag_not_set(erp, 'lock_x', PROPERTY_USAGE_READ_ONLY)


func test_disabled_properties_are_disabled_when_editing_an_instance():
	var erp = EditorRectProperties.new()
	erp._is_instance = true
	erp.set_disabled_instance_properties(['lock_x'])
	assert_property_usage_bit_flag_set(erp, 'lock_x', PROPERTY_USAGE_READ_ONLY)


# --------------------
#endregion

