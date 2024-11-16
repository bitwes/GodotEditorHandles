# Setting which properties are editable
It looks like we can use the ower and/or parent to decide if we are editing the object that has the properties or an instance of it in another scene.  This could be useful in deciding which properties are enabled/disabled/visible when editing the instance.

```
print(self, '|  |', get_parent(), '|  |', owner)
<when editing scene>
ResizableCollisionShape:<Node2D#3590877944875>|  |@SubViewport@9109:<SubViewport#85614136065>|  |<Object#null>
<when editing a scene that contains one of these>
ResizableCollisionShape2:<Node2D#3362120605849>|  |CollisionShapes:<Node2D#3362003165332>|  |ManualResizeTesting:<Node2D#3361768284150>
```


## Put more plugin logic into the control
It seems like more logic could be moved out of the plugin script and into the control.  The plugin may have to call to the control, but the logic could live in the control where it makes more sense.
* input handling


# Demo
* Gap Laser
* Retractable Walls
* Activation Areas
* Platforms (One Ways)