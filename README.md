# EditorRect

You want to make a resizable node.  You want to be able to resize things in the editor when you use your resizable node.  Cool.  This should help.

With this you could do all these things without having "editable children":
* Make a node that has a TextureRect that should be resizable
* Make a node that has a resizable collision shape
* Make a node that has a TextureRect and a collision shape that should be resized together.
* Make those same kinds of things by they are moveable instead of resizable.
* Make those same kinds of things that are resizable and moveable.

# Usage
If anything isn't doing what you think it should, you may need to reload the scene.  I'd suggest mapping "Reload Saved Scene" to a keyboard shortcut to make this easier.

Your thing that uses an `EditorRectProperties` MUST be a `@tool`.


## Add a EditorRectProperties and use it:
```
@tool # IMPORTANT
extends Node2D # or whatever

# I think only one of these will work at a time.  This is all still very new.
@export var resize_properties : EditorRectProperties

func _ready():
    # The source of the magic.  No magic if you don't use this.  You will have
    # to reload the scene after adding this.
	add_child(resize_properties.make_editor_rect(self))
```

## Set the things to resize
Currently supported:
* Controls
* CollisionShape2D whose shapes have a size property.

Set the Node Paths in the "Resizes" array for all the things you want to be resized by the EditorRect.

You can also connect to the `resized` and `moved` signals and change things yourself.  These signals are emitted during design time and run time.

# Install
Once this becomes a real boy it'll be installable through the Asset Library.  Until then:
* copy addons/EditorRect to your project.
* enable the plugin.

