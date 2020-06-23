extends "res://logic/mobs/Mob.gd"

onready var label = $Label
#onready var state_machine = MobStateMachine.new()


func _ready():
	pass
	

func _process(delta):
	match state_machine.state:
		state_machine.states.idle:
			label.text = "IDLE"
		state_machine.states.chasing:
			label.text = "CHASING"
		state_machine.states.attacking:
			label.text = "ATTACKING"
		state_machine.states.patrolling:
			label.text = "PATROLLING"
	
