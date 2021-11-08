extends Controller


func _physics_process(_delta: float) -> void:
	var movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var jump = Input.is_action_just_pressed("jump")
	if movement != 0:
		emit_signal("requested_move", Vector2(movement, 0))
	if jump:
		emit_signal("requested_jump")
