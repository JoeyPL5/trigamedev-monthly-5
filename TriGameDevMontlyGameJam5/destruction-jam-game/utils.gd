extends Node


# replaces first n of what with forwhat in input
func replace_first_n(input : String, what : String, forwhat : String, n : int) -> String:
	var new_str : String = String(input)
	var remaining : int = n
	while remaining > 0 and new_str.contains(what):
		var idx : int = new_str.find(what)
		if idx == -1:
			break
		var prefix : String = new_str.substr(0, idx)
		var suffix : String = new_str.substr(idx + len(what))
		new_str = prefix + forwhat + suffix
		remaining -= 1
	return new_str

# safely increments a dictionary key or instantiates it
func increment_dict_key(dict : Dictionary, key : Variant) -> void:
	if dict.has(key):
		dict[key] += 1
	else:
		dict[key] = 1

# chooses n elements from the array arr
func from_arr_choose_n(arr : Array, n : int) -> Array[Variant]:
	return from_arr_choose_n_conditional(arr, n, func(_any : Variant): return true)

# choosen n elements from the array arr where condition is true
func from_arr_choose_n_conditional(arr : Array, n : int, condition : Callable) -> Array[Variant]:
	var dupe_arr : Array[Variant] = arr.duplicate(false)
	var chosen : Array[Variant] = []
	while len(chosen) < n and len(dupe_arr) > 0:
		var val_idx : int = randi_range(0, len(dupe_arr) - 1)
		var val : Variant = dupe_arr[val_idx]
		if condition.call(val):
			chosen.append(val)
		dupe_arr.erase(val)	
	return chosen
