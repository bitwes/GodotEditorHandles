# As Child of What it edits
* If the editor rect is a child of what it edits, then it can assume some things.





# Issues?
I think the problem is that the editor rect cannot be altered at design time because it is not a child of a parent that has editable children.  In order to make properties stick the parent must have properties that the editor rect can set.  That way it can load and edit these properties at design time then reapply them on load (both design time and run time).


## Solutions?
* I could add a resource that holds the values that the editor rect uses.  If the parent has a property of that type then it can find it, edit it when resized and then that should be reflected.