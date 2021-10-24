extends Node

var current_level: Node

static func map(value: float, istart: float, istop: float, ostart: float, ostop: float) -> float:
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

static func snap(value: float, step: float) -> float:
	return round(value / step) * step

static func approach(a: float, b: float, amount: float) -> float:
	if a < b:
		a += amount
		if a > b:
			return b
	else:
		a -= amount
		if a < b:
			return b
	return a

static func ang2vec(angle) -> Vector2:
	return Vector2(cos(angle), sin(angle))

static func get_angle_from_to(node: Node, position: Vector2) -> Vector2:
	var target = node.get_angle_to(position)
	target = target if abs(target) < PI else target + TAU * -sign(target)
	return target

static func angle_diff(from: float, to: float) -> float:
	return fposmod(to - from + PI, PI * 2) - PI

static func comma_sep(number: float) -> String:
	var string = str(int(number))
	var mod = string.length() % 3
	var res = ""
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]
	return res

static func wave(from: float, to: float, duration: float, offset: float) -> float:
	var t = OS.get_ticks_msec() / 1000.0
	var a = (to - from) * 0.5
	return from + a + sin((((t) + duration * offset) / duration) * TAU) * a

static func frames(num: float) -> float:
	return num * 0.016


func is_in_range(value: float, min_value: float, max_value: float) -> bool:
	return value >= min_value and value < max_value


func get_current_level() -> Node:
	return current_level


func play_sound_in_level(sound: AudioStream) -> void:
	call_deferred("_play_sound_in_level", sound)


func place_in_level(scene: PackedScene, global_position: Vector2) -> void:
	var scene_instance = scene.instance()
	get_current_level().call_deferred("add_child", scene_instance)
	scene_instance.global_position = global_position


func move_to_level(level_node: Node) -> void:
	call_deferred("_move_to_level", level_node)


func _play_sound_in_level(sound_node: AudioStreamPlayer) -> void:
	var sound_node_duplicate = sound_node.duplicate()
	if sound_node_duplicate is AudioStreamPlayer2D:
		sound_node_duplicate.global_position = sound_node.global_position
	get_current_level().add_child(sound_node_duplicate)
	sound_node_duplicate.connect("finished", sound_node_duplicate, "queue_free")
	sound_node_duplicate.play()


func _move_to_level(level_node: Node) -> void:
	level_node.get_parent().remove_child(level_node)
	get_current_level().add_child(level_node)
