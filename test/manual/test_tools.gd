class_name TestTools


static func print_props(what):
	print(what)
	var to_print = []
	for p in what.get_property_list():
		to_print.append(str('  ', p.name, ' = ', what.get(p.name)))

	to_print.sort()
	for entry in to_print:
		print(entry)

