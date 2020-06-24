extends "res://logic/StateMachine.gd"

class_name MobStateMachine


func _ready():
	add_state("idle")
	add_state("chasing")
	add_state("attacking")
	add_state("patrolling")
	add_state("investigating")
	call_deferred("_set_state", states.idle)


func _state_logic(delta):
	match state:
		states.idle:
			parent._stop()
		states.chasing:
			parent._chase_player()
		states.attacking:
			pass
		states.investigating:
			parent._investigate_last_player_spot()
		states.patrolling:
			pass


func _get_transition(delta):
	match state:
		states.idle:
			if parent._should_chase_player():
				return states.chasing
			if parent._should_investigate():
				return states.investigating
		states.chasing:
			if parent._should_chase_player():
				return states.chasing
			else:
				return states.idle
		states.investigating:
			if parent._finished_investigating():
				return states.idle


func _enter_state(new_state, old_state):
	if parent.sprite != null:
		match new_state:
			states.idle:
				parent.sprite.play("stand")
	

func _exit_state(old_state, new_state):
	pass

