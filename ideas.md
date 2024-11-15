# Setting which properties are editable
It looks like we can use the ower and/or parent to decide if we are editing the object that has the properties or an instance of it in another scene.  This could be useful in deciding which properties are enabled/disabled/visible when editing the instance.

```
print(self, '|  |', get_parent(), '|  |', owner)
<when editing scene>
ResizableCollisionShape:<Node2D#3590877944875>|  |@SubViewport@9109:<SubViewport#85614136065>|  |<Object#null>
<when editing a scene that contains one of these>
ResizableCollisionShape2:<Node2D#3362120605849>|  |CollisionShapes:<Node2D#3362003165332>|  |ManualResizeTesting:<Node2D#3361768284150>
```


# Ideas
## I think the resource should do all the resizing.
This means we don't need to make the editor rect when we aren't in the editor.  Since the editor_rect now requires a EditorRectProperties instance it can just call back to that to do the resizing.  The resource can then get a method that would do the resizing that could be called in _ready.
```
func _ready():
    if(Engine.is_editor_hint()):
        editor_rect_props.make_editor_rect(self)
    else:
        editor_rect_props.resize_all_the_things(self)
```

It turns out that resources can get to engine hints.  So it could just be:
```
func _ready():
    editor_rect_props.do_what_you_gotta_do(self)
```


## Put more plugin logic into the control
It seems like more logic could be moved out of the plugin script and into the control.  The plugin may have to call to the control, but the logic could live in the control where it makes more sense.
* input handling




# Demo
* Gap Laser
* Retractable Walls
* Activation Areas
* Platforms (One Ways)