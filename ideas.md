# TODO
* DragSnap should not be looking at difference in size, but position (snap to grid, not incremental size change).
* DragSnap should be applied to movement.
* DragSnap should be zero by default?
* Should DragSnap be a float or int?
* Draw a line from the center of the EditorRect to the parent?
* You can still move the rect when movable is disabled by dragging where the move handle is (even though you can't see it)
* Add a resizable flag
* You can implement min/max sizes and positions in code.  It would be nice if the mouse honored those instead of the dragging just stopping.  Not sure if it is possible to keep the mouse at the same location if the resize/movement doesn't change any values.
* Resizing when scale of parent has been changed is not right.
* Dragging when rotated means you have to drag on a different axis.
* Could use some scaling on the drawing.  Handles are too small when zoomed out.  The handles should be the same size always.
* rotation handles would be cool
* Expand from center option.  Currently it is "expand from center", but it should get an option and have more handles so it can be used both ways.
* when resizing sides, undo should contain a size and position value, otherwise undo doesn't undo the move.
* hide or visibly disable handles when lock_x or lock_y would prevent them from being used.


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