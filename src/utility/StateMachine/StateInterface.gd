class_name StateInterface
extends Node
# State interface for StateMachine


@export var next_state: String = ""
@export var prev_state: String = ""

var host
var active = false


func _enter_tree() -> void:
	var parent = get_parent()
	host = parent.host


func _exit_tree() -> void:
	if active:
		exit()


func queue_state_change(state: String) -> void:
	var state_machine = get_parent()
	# use this if you need to change state externally, or from a signal.
	state_machine.queue_state(state, self)


func enter() -> void:
	# Initialize state 
	pass


# warning-ignore:unused_argument
func update(delta: float) -> void:
	# To use with _process(delta)
	# Return a string, e.g. "Walking", to change states. Otherwise don't return (or return null).
	pass

	
# warning-ignore:unused_argument
func integrate(state: StateInterface) -> void:
	# To use with _integrate_forces(state)
	pass


func exit() -> void:
	#  Cleanup and exit state
	pass
