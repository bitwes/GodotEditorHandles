# TODO
* I think editor_rect_properties needs to make itself local to scene in _init().  This way the user doesn't have to remember to do that.
* DragSnap should not be looking at difference in size, but position (snap to grid, not incremental size change).
* DragSnap should be applied to movement.
* Minimum Size
* Draw a line from the center of the EditorRect to the parent?

# Move resize/move of targets to resource
If the resource does the movement and resizing of nodes then we won't need to add an EditorRect control at runtime.


# Setting which properties are editable
It looks like we can use the owner and/or parent to decide if we are editing the object that has the properties or an instance of it in another scene.  This could be useful in deciding which properties are enabled/disabled/visible when editing the instance.

```
print(self, '|  |', get_parent(), '|  |', owner)
<when editing scene>
ResizableCollisionShape:<Node2D#3590877944875>|  |@SubViewport@9109:<SubViewport#85614136065>|  |<Object#null>
<when editing a scene that contains one of these>
ResizableCollisionShape2:<Node2D#3362120605849>|  |CollisionShapes:<Node2D#3362003165332>|  |ManualResizeTesting:<Node2D#3361768284150>
```

# BIG ISSUE
If the EditorRetProperties changes on the base object it can have bad repercussions wherever it is being used.
* Renaming ruins everything, so that should be strongly discouraged.
* Changing starting values will propigate to any instance in a scene, resetting the value (I'm pretty sure).

If you change the array of things to be resized on the base object, none of the instances will get that change.  This might need to be moved to code instead of an export.


## Two resources?
If there was a resource to hold the list of nodes to be updated, and another resource to hold the properties then that might do something?  The list resource would not be "local to scene" (possibly enforced by code).  This way you could change the list resource and it will propigate, but the actual props would not.  We could probably look for one of these on the parent object in `create_edit_control` to auto detect.  If not, then you'd have to set it with code probably.


## Versioning
There might be a way to put a version property when on the source object.  If the version does not match the source (there might be a tricky way to do this or you just do it in code) then something happens.

## Validation callbacks
If you could tie into the changing of values, then if your rules change you can validate values.  Validation methods would return a bool to indicate if the value should be accepted.-

# Demo
* Gap Laser
* Retractable Walls
* Activation Areas
* Platforms (One Ways)