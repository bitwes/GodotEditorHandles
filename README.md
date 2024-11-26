# EditorHandles
EditorHandles is a resource that, when added to the root node of a scene, provides resize and movement handles for a Node.  This allows you to resize and move children of your Node when used in other scenes.

# Usage
Your thing that uses an `EditorHandles` MUST be a `@tool`.

__!! SUPER VERY IMPORTANT CRITICAL DISCLAIMER !!__<br>
Once you have made your `@export` and you have used your scene in another scene, renaming the exported variable will LOSE ALL SETTINGS IN ALL YOUR INSTANCES.  For this reason, I suggest that you name all your exports the same thing (I've been using `export_handles`).  You can only have one ([right now](#19)) per node, so you don't have to differentiate between multiples on the same object.  Naming them the same everywhere will make it easy to understand what they are and may aleviate the urge to make their names more descriptive.  Think of the `EditorHandles` properties like the properties in the `Transform` or `Visibility` section of a Node.

__LESS IMPORTANT DISCLAIMER__<br>
All `EditorHandles` resources are ALWAYS "local to scene".  This means that if you need to enforce a value or change defaults, you must do this in code.  This was done because, by the nature of what `EditorHandles` aims to do, you don't want the resource to be shared across multiple instances.  You also don't want to accidently change values everywhere when you edit the source node.  The downside is that if you want to change a value everywhere, you can't do that in the source Node's `EditorHandles`, you must do that in code.

## Add an EditorHandles property and use it:
```
@tool # IMPORTANT
extends Node2D # or whatever

# You should NEVER rename this variable, See the SUPER VERY IMPORTANT CRITICAL
# DISCLAIMER in this README for more information.
@export var editor_handles : EditorHandles

func _ready():
    if(Engine.is_editor_hint()):
        editor_handles.changed.connect(_apply_editor_handles)
        editor_handles.editor_setup(self)

    _apply_editor_handles()

# Example of resizing and moving a TextureRect when handles are moved.  You must
# implement both size and position if what you resize is not `ExpandFromCenter` only.
func _apply_editor_handles():
    $TextureRect.size = editor_handles.size
    $TextureRect.position = editor_handles.position - $TextureRect.size / 2
```

## Disable/Hide Properties
You may want to permanently disable or hide properties in instances of your scene so that they are easier to use and don't introduce issues.  For example, if your node has a fixed width, you may want to hide or disable the `lock_x` and `lock_x_value` properties where the Node is being used.  You can do this with the `set_disabled_instance_properties` and `set_hidden_instance_properties` in `_ready`.

In this example we are hiding `lock_x`, and disabling `lock_x_value`.  Maybe you don't want to even think about being able to disable `lock_x`, but you want to see `lock_x_value` so that you know why you can't change the x value.

`set_disabled_instance_properties` and `set_hidden_instance_properties` accept an array of property names.  Calling these multiple times will override any previous call.
```gdscript
@export var editor_handles : EditorHandles

func _ready():
    if(Engine.is_editor_hint()):
        editor_handles.changed.connect(_apply_editor_handles)
        editor_handles.set_hidden_instance_properties(['lock_x'])
        editor_handles.set_disabled_instance_properties(['lock_x_value'])
        editor_handles.editor_setup(self)

    _apply_editor_handles()

```

# Install
* Downlaod the zip:  https://github.com/bitwes/GodotEditorHandles/archive/refs/heads/main.zip
* Copy `addons/editor_handles` from the zip to your project.
* Enable the "EditorHandles" plugin in Project Settings.


__IMPORTANT NOTE ABOUT UPDATING__<br>
If you are upgrading, make sure to backup your project before you test the new version.  I think I've avoided any issues where updates could cause instances to lose property values, but I've been wrong a couple times.  After updating you should spot check places where your instances are being used to be sure they didn't lose any properties.  Once I'm sure that I know how to not break things I'll probably add this to the Asset Library.

# Screenshots
This is a node that has a `CollsionShape2D` that can be resized in another scene.
![image](https://github.com/user-attachments/assets/895c6df6-c750-43d3-b5db-1409f121cc09)

Here you can see the collision shape being resized in another scene.
![image](https://github.com/user-attachments/assets/9f1c1cc7-3e04-48b1-b835-0d9dcf966e6c)



