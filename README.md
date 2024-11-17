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

# Screenshots
This is a node that has a `CollsionShape2D` that can be resized in another scene.
![image](https://github.com/user-attachments/assets/895c6df6-c750-43d3-b5db-1409f121cc09)

Here you can see the collision shape being resized in another scene.
![image](https://github.com/user-attachments/assets/9f1c1cc7-3e04-48b1-b835-0d9dcf966e6c)



