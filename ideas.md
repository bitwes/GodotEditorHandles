# TODO
* DragSnap should not be looking at difference in size, but position (snap to grid, not incremental size change).
* DragSnap should be applied to movement.
* DragSnap should be zero by default?
* Should DragSnap be a float or int?
* Draw a line from the center of the EditorRect to the parent?
* You can still move the rect when movable is disabled by dragging where the move handle is (even though you can't see it)
* Add a resizable flag
* You can implement min/max sizes and positions in code.  It would be nice if the mouse honored those instead of the dragging just stopping.  Not sure if it is possible to keep the mouse at the same location if the resize/movement doesn't change any values.


# How to break everything
* Rename the variable.  Renaming the variable will lose all settings on all instances.
    * I doubt there is anything that can be done to about this, but it would be nice.
* Changing values on the source object will not propigate.  If you need to enforce values, set them in code.


# Validation callbacks
If you could tie into the changing of values, then if your rules change you can validate values.  Validation methods would return a bool to indicate if the value should be accepted.-

# Demo
* Gap Laser
* Retractable Walls
* Activation Areas
* Platforms (One Ways)