class_name StateMachine
extends Node


signal state_changed(_states_stack)

# if you are using both of these, make sure you don't update the 
# AnimatedSprite's current animation with the AnimationPlayer - this will be 
# done automatically if the state name matches the animation name.
@export var animation_player_nodepath: NodePath
@export var animated_sprite_nodepath: NodePath
@export var initial_state: String = ""

var state: StateInterface
var state_ready: bool = false
var initialized: bool = false

var _animation_player: WeakRef
var _animated_sprite: WeakRef
var _states_stack: Array = []
var _states_map: Dictionary = {}
var _queued_state_change: String = ""
var host: Node


func _ready() -> void:
	state_ready = true
	_animated_sprite = weakref(get_node_or_null(animated_sprite_nodepath))
	_animation_player = weakref(get_node_or_null(animation_player_nodepath))
	if (initial_state != "") and (initial_state != null):
		_change_state(initial_state)


func _enter_tree() -> void:
	host = get_parent()


func init(st: String = "") -> void:
	if ! state_ready:
		await Signal(ready)
	# Must be called with array of states before anything.
	# The first state in the array is the starting state for the machine, unless specified with the 
	# st param.
	var states_array = get_children()
	# assert(states_array, "State machine for %s has no states!" % host.get_name())
	assert(states_array, "This state machine has no states!")
	for new_state in states_array:
		if new_state is StateInterface:
			_states_map[new_state.get_name()] = new_state
		else:
			print("Invalid state %s for node %s" % [new_state.get_name(), host.get_name()])
			new_state.queue_free()
	if st != "":
		_change_state(_states_map[st].get_name())
	else:
		_change_state(states_array[0].get_name())
	initialized = true


func queue_state(new_state_name: String, old_state: StateInterface) -> void:
	if old_state.active:
		_queued_state_change = new_state_name


func update(delta: float) -> void:
	# https://github.com/godotengine/godot/issues/47157
	# assert(initialized, "State machine uninitialized for %s!" % host.get_name())
	assert(initialized, "State machine uninitialized for the given state!")
	# call this in _physics_process
	if _queued_state_change != "":
		_change_state(_queued_state_change)
		_queued_state_change = ""
		return
	var next_state_name: Variant = state.update(delta)
	if (next_state_name != "") and (next_state_name != null):
		_change_state(next_state_name)


func try(method: String, args: Array = []) -> void:
	if state.has_method(method):
		state.callv(method, args)


func deactivate() -> void:
	state.active = false
	state.exit()


func integrate(st: StateInterface) -> void:
	# call this for rigidbodies
	state.integrate(st)


func _change_state(state_name: String) -> void:
	# Sets current state value to input, exits & cleans up previous state, and enters new one.
	var next_state

	# Special case if keyword "Previous" is passed. State machine returns to previous state.
	if state_name == "Previous":
		_states_stack.pop_front()
		next_state = _states_stack[0]
	else:
		next_state = _states_map[state_name]
	if state:  # if there is a currently running state, exit it
		state.exit()
		state.active = false

	state = next_state
	_states_stack.push_front(state)
	state.active = true
	state.enter()

	var animation_player_ref = self._animation_player.get_ref()
	if animation_player_ref != null and animation_player_ref.has_animation(state_name):
		animation_player_ref.play(state_name)
	
	var animated_sprite_ref = self._animated_sprite.get_ref()
	if animated_sprite_ref != null and animated_sprite_ref.frames.has_animation(state_name):
		animated_sprite_ref.frame = 0
		animated_sprite_ref.play(state_name)

	emit_signal("state_changed", _states_stack)

