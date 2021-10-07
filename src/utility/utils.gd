extends Node

var current_level

static func map(value, istart, istop, ostart, ostop):
	return ostart + (ostop - ostart) * ((value - istart) / (istop - istart))

static func tree_set_all_process(p_node: Node, p_active: bool, p_self_too: bool = false) -> void:
	if not p_node:
		push_error("p_node is empty")
		return
	var p = p_node.is_processing()
	var pp = p_node.is_physics_processing()
	p_node.propagate_call("set_process", [p_active])
	p_node.propagate_call("set_physics_process", [p_active])
	if not p_self_too:
		p_node.set_process(p)
		p_node.set_physics_process(pp)

static func snap(value, step):
	return round(value / step) * step

static func approach(a, b, amount):
	if a < b:
		a += amount
		if a > b:
			return b
	else:
		a -= amount
		if a < b:
			return b
	return a

static func ang2vec(angle):
	return Vector2(cos(angle), sin(angle))

static func get_angle_from_to(node, position):
	var target = node.get_angle_to(position)
	target = target if abs(target) < PI else target + TAU * -sign(target)
	return target
	
static func angle_diff(from, to):
	return fposmod(to-from + PI, PI*2) - PI
	
static func comma_sep(number):
	var string = str(int(number))
	var mod = string.length() % 3
	var res = ""
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]
	return res

static func wave(from, to, duration, offset):
	var t = OS.get_ticks_msec() / 1000.0
	var a = (to - from) * 0.5
	return from + a + sin((((t) + duration * offset) / duration) * TAU) * a

static func frames(num):
	return num * 0.016

func is_in_range(val, min_, max_):
	return val >= min_ and val < max_

func get_current_level():
	return current_level

func play_sound_in_level(sound):
	call_deferred("_play_sound_in_level", sound)
	
func _play_sound_in_level(sound_: Node):
	var sound = sound_.duplicate()
	if sound is Node2D:
		sound.global_position = sound_.global_position
	get_current_level().add_child(sound)
	sound.connect("finished", sound, "queue_free")
	sound.play()

func place_in_level(scene, global_position):
	var scene_instance = scene.instance()
	get_current_level().call_deferred("add_child", scene_instance)
	scene_instance.global_position = global_position

func move_to_level(node):
	call_deferred("_move_to_level", node)

func _move_to_level(node):
	node.get_parent().remove_child(node)
	get_current_level().add_child(node)

static func remove_duplicates(array: Array):
	var seen = []
	var new = []
	for i in array.size():
		var value = array[i]
		if value in seen:
			continue
		seen.append(value)
		new.append(value)
	return new
