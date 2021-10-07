extends Node

class_name StateMachine

var states_stack = []
var states_map = {}
var state: StateInterface
var queued_state_change

var initialized = false

# only one of these will be used, prioritizing the animation player. filling in
# both is useless.
export(NodePath) var animation_player
export(NodePath) var animated_sprite

signal state_changed(states_stack)

var host
var ready = false

func _ready():
	ready = true
	animated_sprite = weakref(get_node_or_null(animated_sprite))
	animation_player = weakref(get_node_or_null(animation_player))

func _enter_tree():
	host = get_parent()

func init(st: String="") -> void:
	if !ready:
		yield(self, "ready")
	# Must be called with array of states before anything.
	# The first state in the array is the starting state for the machine, unless specified with the 
	# st param.
	var states_array = get_children()
	assert(states_array, "State machine for %s has no states!" % host.get_name())
	for new_state in states_array:
		if new_state is StateInterface:
			states_map[new_state.get_name()] = new_state
		else:
			print("Invalid state %s for node %s" % [new_state.get_name(), host.get_name()])
			new_state.queue_free()
	if st != "":
		_change_state(states_map[st].get_name())
	else:
		_change_state(states_array[0].get_name())
	initialized = true

func queue_state(new_state, old_state) -> void:
	if old_state.active:
		queued_state_change = new_state

func update(delta) -> void:
	assert(initialized, "State machine uninitialized for %s!" % host.get_name())
	# call this in _physics_process
	if queued_state_change:
		_change_state(queued_state_change)
		queued_state_change = null
		return
	var next_state_name = state.update(delta)
	if next_state_name:
		_change_state(next_state_name)

func deactivate() -> void:
	state.active = false
	state.exit()

func integrate(st) -> void:
	# call this for rigidbodies
	state.integrate(st)

func _change_state(state_name: String) -> void:
	# Sets current state value to input, exits & cleans up previous state, and enters new one.
	var next_state

	# Special case if keyword "previous" is passed. State machine returns to previous state.
	if state_name == "Previous":
		states_stack.pop_front()
		next_state = states_stack[0]
	else:
		next_state = states_map[state_name]
	if state: # if there is a currently running state, exit it
		state.exit()
		state.active = false
		
	state = next_state
	states_stack.push_front(state)
	state.active = true
	state.enter()
	
	var animation_player = self.animation_player.get_ref()
	if animation_player != null and animation_player.has_animation(state_name):
		animation_player.play(state_name)
	else:
		var animated_sprite = self.animated_sprite.get_ref()
		if animated_sprite != null and animated_sprite.frames.has_animation(state_name):
			animated_sprite.frame = 0
			animated_sprite.play(state_name)
	
	emit_signal("state_changed", states_stack)

func try(method: String, args: Array = []):
	if state.has_method(method):
		state.callv(method, args)
