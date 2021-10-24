extends Node


var enabled: bool = true
var items: Dictionary = {}
var times: Dictionary = {}
var dbg_function: FuncRef


func _enter_tree() -> void:
	if enabled:
		dbg_function = funcref(self, "dbg_enabled")
	else:
		dbg_function = funcref(self, "dbg_disabled")


func _process(_delta: float) -> void:
	#yield(get_tree(), "idle_frame")
	for time_array in times:
		var total_time = 0
		var counter = 0
		for time in times[time_array]:
			counter += 1
			total_time += time.length
		dbg(time_array, total_time)
		dbg(time_array + " avg", total_time / float(counter))
		dbg_max(time_array + " max", total_time)


class Time:
	var length: float
	var name: String

	func _init(init_name: String, init_length: float):
		self.name = init_name
		self.length = init_length / 1000.0


func time_function(object: Object, method: String, args: Array) -> void:
	var start = OS.get_ticks_usec()
	object.callv(method, args)
	var end = OS.get_ticks_usec()
	if times.has(method):
		times[method].append(Time.new(method, end - start))
	else:
		times[method] = [Time.new(method, end - start)]


func dbg_enabled(id, value) -> void:
	items[id] = value


func dbg_disabled(_id, _value) -> void:
	pass


func dbg(id, value) -> void:
	dbg_function.call_func(id, value)


func dbg_count(id, value, min_value: float = 1.0) -> void:
	if value >= min_value:
		dbg(id, value)


func dbg_remove(id) -> void:
	#warning-ignore:return_value_discarded
	items.erase(id)


func dbg_max(id, value) -> void:
	if ! items.has(id) or items[id] < value:
		dbg(id, value)


func lines() -> Array:
	var lines = []
	for id in items:
		lines.append(str(id) + ": " + str(items[id]))
	return lines
