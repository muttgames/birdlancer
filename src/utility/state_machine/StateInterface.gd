extends Node

class_name StateInterface

# State interface for StateMachine
var host
var active = false

signal queue_state_change(state, self_)

func queue_state_change(state: String) -> void:
	var state_machine = get_parent()
	# use this if you need to change state externally, or from a signal.
	state_machine.queue_state(state, self)

func _enter_tree() -> void:
	var parent = get_parent()
	host = parent.host

func enter() -> void:
	# Initialize state 
	pass

func update(_delta):
	# To use with _process(delta)
	# Return a string, e.g. "Walking", to change states. Otherwise don't return (or return null).
	pass
	
func integrate(_state) -> void:
	# To use with _integrate_forces(state)
	pass

func exit() -> void:
	#  Cleanup and exit state
	pass

func _exit_tree() -> void:
	if active:
		exit()
