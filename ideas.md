# TODO
* Draw a line from the center of the EditorRect to the parent?
* You can implement min/max sizes and positions in code.  It would be nice if the mouse honored those instead of the dragging just stopping.  Not sure if it is possible to keep the mouse at the same location if the resize/movement doesn't change any values.
* rotation handles would be cool
* when resizing sides, undo should contain a size and position value, otherwise undo doesn't undo the move.
* Do I need to honor the currently selected editor mode (move, resize, rotate, scale, etc)?
* Change cursor when dragging?
* Handle scaling is affected by node scale.  It should not be.
* Can push around nodes when resizing sizes past an enforced minimum.


# Handle drawing resource
Could add a bunch of handle drawing resources, and allow the user to make their own so that they can make handles look however they'd like.  Or maybe just a callback, or something.  IDK.  Resource would have to have a `_draw_on(draw_on, handle)` that they could then use `draw_on.draw_rect(handle.rect)` or something like that.  Might need a scale passed in.  Who really knows, I'm tired but just keep typing.


# How to break everything
* Rename the variable.  Renaming the variable will lose all settings on all instances.
    * I doubt there is anything that can be done to about this, but it would be nice.
* Changing values on the source object will not propigate.  If you need to enforce values, set them in code.


# Validation callbacks
If you could tie into the changing of values, then if your rules change you can validate values.  Validation methods would return a bool to indicate if the value should be accepted.


# Property Properties Resource
Another resource could be created that makes it a little easier to set visible/editable properties for instances.  You would have to hide this yourself in `_validate_property` in whatever was using it.  Might have to expose `is_instance` somewhere so users could use it to hide it.


# Demo
* Gap Laser
* Retractable Walls
* Activation Areas
* Platforms (One Ways)


# What's it do?
Allows you to make a tool node that has parts that can be resized and moved while in other scenes.  It could maybe scale and probably rotate.  I don't think it could skew.  So it's like a transform but you swap out scale for size.  At least for now.



# Best Names
- Rectable
- RectEd/Rected
- Rectangler
- GoditorRect
- LessEditableChildren
- EditorHandles


# Reference Material
## Editor plugin to draw/resize
GDQuest:   How to Create a 2d Manipulator in Godot 3.1: Editor Plugin Overview
https://www.youtube.com/watch?v=H6TfKYtuM9U
GDQuest:  Canvas Input, Undo, and Redo in Godot: Plugin Tutorial 2
https://www.youtube.com/watch?v=RDx5B_AzkPI

## Getting snap settings
https://github.com/godotengine/godot-proposals/issues/10529