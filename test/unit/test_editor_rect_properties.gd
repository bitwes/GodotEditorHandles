extends GutTest

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


func test_can_make_one():
	var erp = EditorRectProperties.new()
	assert_not_null(erp)


func test_new_erp_is_local_to_scene():
	var erp = EditorRectProperties.new()
	assert_true(erp.resource_local_to_scene)


func test_default_disabled_properties(p = use_parameters([
				"lock_x_value",	"lock_y_value", "position"])):
	var erp = EditorRectProperties.new()
	var prop_props = find_property(p, erp.get_property_list())
	assert_false(prop_props.is_empty(), str('prop ', p, ' was found'))
	assert_bit_flag_set(prop_props.usage, PROPERTY_USAGE_READ_ONLY, str(' on ', p))


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


