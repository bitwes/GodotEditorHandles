# Adapted from https://github.com/godotengine/godot-proposals/issues/10529

## Finds the first child with a name containing child_name.  If expected_type is
## specified, this will check to be sure what is found is of the expected type.
## If a child with the name is not found or it is not of the expected type then
## an error is generated and null is returned.
func find_child_with_name_containing(parent, child_name, expected_type = null):
	var to_return = parent.find_child("*%s*" % child_name, true, false)

	if(to_return == null):
		push_error("Could not find child named ", child_name, " in ", parent)
	elif(expected_type != null and not is_instance_of(to_return, expected_type)):
		push_error("Expected ", to_return, ' to be an instance of ', expected_type)
		to_return = null

	return to_return


## Gets the child at index index if it exists.  If it does not a friendlier
## error is generated and null is returned.  If expected_type is specified this
## will verify the found child is of the expected type.  If it is not of the
## expected type then an error is generated and null is returned.
func safe_get_child(parent, index, expected_type = null):
	if(parent != null and index < parent.get_child_count()):
		var found = parent.get_child(index)
		if(expected_type != null and not is_instance_of(found, expected_type)):
			push_error("Expected ", found, ' to be an instance of ', expected_type)
			found = null
		return found
	else:
		push_error(str("Could not get child index ", index, " on ", parent, '.  ', parent, ' has ', parent.get_child_count(), ' children.'))
		return null


## Takes a parent node and an array of indexes/strings and walks down the tree.
## Null will be returned if any child cannot be found.  If expected_type is
## set, it will validate that what is found is of the expected type.  If it is
## not, null is returned.
##
## Examples:
##	safe_get_descendant(main_screen, [0, 2, 0])
##		same as calling main_screen.get_child(0).get_child(2).get_child(0)
## safe_get_descendant(foo, ["NodeWithThisName", 0, 5, 9])
##		same as calling nice_fild_child(foo, "NodeWithThisName").get_child(0).get_child(5).get_child(9)
func safe_get_descendant(parent, names_and_or_indexes, expected_type = null):
	var here = parent
	var index = 0

	while(here != null and index < names_and_or_indexes.size()):
		var entry = names_and_or_indexes[index]
		if(typeof(entry) == TYPE_STRING):
			here = find_child_with_name_containing(here, entry)
		elif(typeof(entry) == TYPE_INT):
			here = safe_get_child(here, entry)
		index += 1

	if(here != null and expected_type != null and not is_instance_of(here, expected_type)):
		push_error("Expected ", here, ' to be an instance of ', expected_type)
		here = null

	return here


var descendant_props_to_print = ['text', 'value']
## A variation of print_tree that prints children in the order they are in
## the tree.  Their index is included in the output.  This will also print
## any properties in descendant_props_to_print that the child has.
func print_descendants(parent, indent='', child_index = -1):
	var text = ""
	if(child_index != -1):
		text = str(indent, '[', child_index, '] ', parent)
	else:
		text = str(indent, parent)

	for ptp in descendant_props_to_print:
		if(parent.get(ptp) != null):
			text += str(' ', ptp, ' = ', parent.get(ptp))
	print(indent, text)

	for i in range(parent.get_child_count()):
		print_descendants(parent.get_child(i), indent + '  ', i)


## Limited info from get_method_list.
func print_methods_simple(thing):
	print(thing, ' methods:')
	for method in thing.get_method_list():
		print('  ', method.name)


## Prints the names and values of all properties thing has.
func print_properties_and_values(thing):
	print(thing, ' properties:')
	for prop in thing.get_property_list():
		print("  ", prop.name, ' = ', thing.get(prop.name))