class_name DebugLabel
extends Label


func _process(_delta: float) -> void:
	text = ""
	for line in Debug.lines():
		text = text + line + "\n"
