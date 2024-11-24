@tool
extends Resource
class_name EditorHandles


# ------------------------------------------------------------------------------
# Class
# ------------------------------------------------------------------------------
# used to prevent signals from firing when a property is being set in a signal
# handler (such as clamping the position or size).
var _is_currently_setting_property = false
var _handles_ctrl : EditorHandlesControl = null
var _is_instance = false
var _hidden_props := []
var _disabled_props := []

## When resizing, it will expand in all directions from the center.
@export var expand_from_center := true :
	set(val):
		expand_from_center = val
		_apply_properties_to_handles_ctrl()

## Enable/disable resizing the rect.
@export var resizable := true :
	set(val):
		resizable = val
		_emit_signals([changed])

## It's the size...width and height, as you would expect.
@export var size := Vector2(100, 100) :
	set(val):
		size = val
		_apply_properties_to_handles_ctrl()
		_emit_signals([resized, changed])

## Enable/disable locking the width of the rect.  Disabled when y_lock enabled.
@export var lock_x := false :
	set(val):
		lock_x = val
		if(lock_x):
			size.x = lock_x_value
			_apply_properties_to_handles_ctrl()
		_disable_handles_for_locks()
		_emit_signals([changed])

## The locked width value
@export var lock_x_value := 0 :
	set(val):
		lock_x_value = val
		if(lock_x):
			size.x = val
			_apply_properties_to_handles_ctrl()
		_emit_signals([changed])

## Enable/Disable locking the height of the rect.  Disabled when x_lock enabled.
@export var lock_y := false :
	set(val):
		lock_y = val
		if(lock_y):
			size.y = lock_y_value
		_disable_handles_for_locks()
		_emit_signals([changed])

## The locked height value
@export var lock_y_value := 0 :
	set(val):
		lock_y_value = val
		if(lock_y):
			size.y = val
		_emit_signals([changed])

## Whether the rect is moveable.  There will be a handle in the middle that you
## can use to drag it about.
@export var moveable := false :
	set(val):
		moveable = val
		_emit_signals([changed])

## The position of the rect, enabled only when moveable.
@export var position := Vector2.ZERO:
	set(val):
		position = val
		_apply_properties_to_handles_ctrl()
		_emit_signals([moved, changed])

## NOT IMPLMENTED YET.  Snap resizing/movement to this increment.
@export var drag_snap : Vector2 =  Vector2(1, 1)

var handles = {} :
	get():
		if(_handles_ctrl != null):
			return _handles_ctrl._handles
	set(val):
		push_error('handles is not settable')

## Emitted when size changes  You can also use the signal "changed".
signal resized
## Emitted when position changes.  You can also use the signal "changed".
signal moved


func _init() -> void:
	# This resource should always be local to scene since that is what it is
	# created for.
	resource_local_to_scene = true


# Set properties only if different to avoid recursion.
func _apply_properties_to_handles_ctrl():
	if(_handles_ctrl != null):
		if(_handles_ctrl.size != size):
			_handles_ctrl.size = size
		if(_handles_ctrl.position != position):
			_handles_ctrl.change_position(position)
		_handles_ctrl.queue_redraw()


func _validate_property(property: Dictionary):
	# Not supported yet so it is always hidden.  Already in use so I didn't
	# want to remove it.
	if property.name == "drag_snap":
		property.usage ^= PROPERTY_USAGE_EDITOR

	if property.name == "lock_x" and (lock_y or !resizable):
		property.usage |= PROPERTY_USAGE_READ_ONLY

	if property.name == "lock_y" and (lock_x or !resizable):
		property.usage |= PROPERTY_USAGE_READ_ONLY

	if property.name == "lock_x_value" and (!lock_x or !resizable):
		property.usage |= PROPERTY_USAGE_READ_ONLY

	if property.name == "lock_y_value" and (!lock_y or !resizable):
		property.usage |= PROPERTY_USAGE_READ_ONLY

	if property.name == "position" and !moveable:
		property.usage |= PROPERTY_USAGE_READ_ONLY

	if property.name == "size" and !resizable:
		property.usage |= PROPERTY_USAGE_READ_ONLY

	if(_is_instance):
		if(property.name in _hidden_props):
			property.usage ^= PROPERTY_USAGE_EDITOR
		elif(property.name in _disabled_props):
			property.usage |= PROPERTY_USAGE_READ_ONLY



func _emit_signals(signal_list : Array[Signal]):
	notify_property_list_changed()
	if(!_is_currently_setting_property):
		_is_currently_setting_property = true
		for s in signal_list:
			if(s == changed):
				emit_changed()
			else:
				s.emit()
		_is_currently_setting_property = false


func _disable_handles_for_locks():
	if(_handles_ctrl != null):
		for key in ['tl', 'tr','br', 'bl']:
			_handles_ctrl._handles[key].disabled = lock_x or lock_y

		for key in ['cr', 'cl']:
			_handles_ctrl._handles[key].disabled = lock_x

		for key in ['ct', 'cb']:
			_handles_ctrl._handles[key].disabled = lock_y


## Call this in ready.  You probably want to call this only when
## `Engine.is_editor_hint()` is true, but it won't hurt anything if you do it
## all the time.
## for_what should ALWAYS be the root node of the scene.  I don't think there is
## a way to determine what this resource is for, so you have to tell it.  Also
## the control has to be added to the root node for it to be found by the plugin
## when selecting the node in other scenes.
func editor_setup(for_what):
	var to_return  = EditorHandlesControl.new(self)
	_is_instance = for_what.owner != null
	to_return.position = position
	to_return.size = size
	resized.emit()
	moved.emit()
	_handles_ctrl = to_return
	for_what.add_child(to_return)
	_disable_handles_for_locks()
	return to_return


func runtime_setup(for_what):
	var to_return  = EditorHandlesRuntimeControl.new(self)
	_is_instance = for_what.owner != null
	to_return.position = position
	to_return.size = size
	resized.emit()
	moved.emit()
	_handles_ctrl = to_return
	for_what.add_child(to_return)
	_disable_handles_for_locks()
	return to_return



## The names of properties that should not appear in the inspector when editing
## instances of this scene.  This does not prevent the values from being
## changed in code.
func set_hidden_instance_properties(to_hide : Array):
	_hidden_props = to_hide
	notify_property_list_changed()


## The names of propeties that should always be disabled in the inspector when
## editing instances of this scene.  This does not prevent the values from
## being changed in code.
func set_disabled_instance_properties(to_disable : Array):
	_disabled_props = to_disable
	notify_property_list_changed()
