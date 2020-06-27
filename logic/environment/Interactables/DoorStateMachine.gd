extends "res://logic/StateMachine.gd"

class_name DoorStateMachine

func _state_logic(delta):
	match state:
		states.open:
			parent.door_animation.play("open")
		states.closed:
			parent.door_animation.play("closed")
			
func _get_transition(delta):
	match state:
		states.opening:
			parent.door_collision.disabled = true
			return states.open
		states.closing:
			parent.door_collision.disabled = false
			return states.closed

func _enter_state(new_state, old_state):
	pass
	
func _exit_state(old_state, new_state):
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	add_state("open")
	add_state("opening")
	add_state("closed")
	add_state("closing")
	call_deferred("_set_state", states.closed)
	
func open_door():
	_set_state(states.opening)
	parent.door_animation.play("opening")
	

func close_door():
	_set_state(states.closing)
	parent.door_animation.play("closing")




