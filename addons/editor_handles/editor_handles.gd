@tool
extends Resource
class_name EditorHandles
# ------------
# Static
# ------------
static var _engine_global = Engine

## Use in the setter for your editor handles.  Preserves unique (local_to_scene)
## EditorHandles instances when duplicating the object in the editor.
static func get_valid_editor_handles_instance(for_what, new_value):
	if(new_value == null):
		return null

	var to_return = new_value
	if(new_value._for_what != null and for_what != new_value._for_what):
		to_return = new_value.duplicate()
		to_return._for_what = for_what
	else:
		new_value._for_what = for_what

	for_what.ready.connect(func():
		to_return._auto_editor_setup(),
		CONNECT_ONE_SHOT
	)

	return to_return




# ------------
# Local
# ------------
# used to prevent signals from firing when a property is being set in a signal
# handler (such as clamping the position or size).
var _is_currently_setting_property = false
var _handles_ctrl : EditorHandlesControl = null :
	set(val):
		if(_handles_ctrl == null):
			_handles_ctrl = val
		else:
			push_warning('Cannot set EHC again.  Ignore this warning for duplicates.')
var _is_instance = false
var _hidden_props := []
var _disabled_props := []
var _for_what = null


## When resizing, it will expand in all directions from the center.  When
## false, resizing will only resize the sides being dragged and the position
## will change to keep the undragged sides at the same location.
@export var expand_from_center := true :
	set(val):
		expand_from_center = val
		_apply_properties_to_handles_ctrl()
## Incremental resize.  Takes precedence over snap settings.  Setting size
## manually not affected by snap.  Resize Snap only checks the drag distance,
## not that the size is a multiple of Resize Snap.  Set to (0,0) to disable.
@export var resize_snap := Vector2.ZERO

## Enable/disable resizing.
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

## Enable/disable locking the width.  Disabled when y_lock enabled.
## Causes all handles except the center side handles to be removed.
## Changes made to the x value for size will be immediately reverted.
@export var lock_x := false :
	set(val):
		lock_x = val
		if(lock_x):
			size.x = lock_x_value
			_apply_properties_to_handles_ctrl()
		_disable_handles_for_locks()
		_emit_signals([changed])

## The locked width value.  Disabled when lock_x is false.
@export var lock_x_value := 0 :
	set(val):
		lock_x_value = val
		if(lock_x):
			size.x = val
			_apply_properties_to_handles_ctrl()
		_emit_signals([changed])

## Enable/Disable locking the height.  Disabled when x_lock enabled.
## Causes all handles except the center top and bottom handles to be removed.
## Changes made to y value for size will be immediately reverted.
@export var lock_y := false :
	set(val):
		lock_y = val
		if(lock_y):
			size.y = lock_y_value
		_disable_handles_for_locks()
		_emit_signals([changed])

## The locked height value.  Disabled when lock_y is false.
@export var lock_y_value := 0 :
	set(val):
		lock_y_value = val
		if(lock_y):
			size.y = val
		_emit_signals([changed])

## Whether the EditorHandles is moveable.  There will be a handle in the middle
## that you can use to drag it about when this is enabled.
@export var moveable := false :
	set(val):
		moveable = val
		_emit_signals([changed])

## The position, only enabled only when moveable.
@export var position := Vector2.ZERO:
	set(val):
		position = val
		_apply_properties_to_handles_ctrl()
		_emit_signals([moved, changed])


## Emitted when size changes  You can also use the signal "changed".
signal resized
## Emitted when position changes.  You can also use the signal "changed".
signal moved

func p(p1='', p2='', p3='', p4='', p5='', p6='', p7='', p8='', p9='', p10='', ):
	print("EHRes", self, '::', _handles_ctrl, ':  ', str(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10))


func _init() -> void:
	# This resource should always be local to scene since that is what it is
	# created for.
	resource_local_to_scene = true
	# p("new resource")


# Set properties only if different to avoid recursion.
func _apply_properties_to_handles_ctrl():
	if(_handles_ctrl != null):
		if(_handles_ctrl.size != size):
			_handles_ctrl.size = size
		if(_handles_ctrl.position != position):
			_handles_ctrl.change_position(position)
		_handles_ctrl.queue_redraw()


func _validate_property(property: Dictionary):
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


func _create_editor_handles_ctrl(for_what):
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


func _auto_editor_setup():
	if(_handles_ctrl == null):
		_create_editor_handles_ctrl(_for_what)
		_disable_handles_for_locks()
	resized.emit()
	moved.emit()


## Call this in ready.  You probably want to call this only when
## `Engine.is_editor_hint()` is true, but it won't hurt anything if you do it
## all the time.
## for_what should ALWAYS be the root node of the scene.  I don't think there is
## a way to determine what this resource is for, so you have to tell it.  Also
## the control has to be added to the root node for it to be found by the plugin
## when selecting the node in other scenes.
func editor_setup(for_what : Variant) -> EditorHandlesControl:
	push_warning("editor_setup is deprecated use the new stuff")
	if(!_engine_global.is_editor_hint()):
		return null
	_for_what = for_what
	var to_return  = _create_editor_handles_ctrl(for_what)
	_disable_handles_for_locks()
	resized.emit()
	moved.emit()
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
