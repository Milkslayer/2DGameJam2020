extends KinematicBody2D

class_name Mob

var stats
var state_machine_script = preload("res://logic/mobs/MobStateMachine.gd")
var state_machine

export var health = 0
export var damage = 0
export var speed = 0
export var difficulty = 0

onready var sprite = $MobSprite

var velocity = Vector2()
var weapon = null
var label = null

var player
var last_player_position

enum Direction{
	UP = 0,
	RIGHT = 1, 
	DOWN = 2,
	LEFT = 3
}


func _ready():
	stats = MobStats.new()
	
	state_machine = Node.new()
	state_machine.set_script(state_machine_script)
	state_machine.name = "MobStateMachine"
	add_child(state_machine)
	
	stats._initialize_mob_stats(difficulty, health, speed, damage)
		
	if self.name != "Cat":
		if get_node("Weapon") != null:
			weapon = get_node("Weapon")
			weapon.get_child(0).set_damage(stats.damage)
	label = get_node("Label")


func _process(delta):
	var state
	if get_tree().get_root().get_node("Game").DEBUG:
		match state_machine.state:
			state_machine.states.idle:
				state = "IDLE"
			state_machine.states.chasing:
				state = "CHASING"
			state_machine.states.attacking:
				state = "ATTACKING"
			state_machine.states.patrolling:
				state = "PATROLLING"
			state_machine.states.investigating:
				state = "INVESTIGATING"

	var text = "STATE: %s\nHEALTH: %d\nDMG_PER_HIT: %d\nSPEED: %d\nDIFFICULTY: %d" % [state, stats.health, stats.damage, stats.speed, stats.difficulty]
	label.text = text
	
func _stop():
	velocity = Vector2()


func _chase_player():
	if _should_chase_player():
		var direction = self.position.direction_to(player.position).normalized()
		rotate_sprite(direction)
		velocity = direction * stats.speed
		move_and_slide(velocity)

func _investigate_last_player_spot():
	var direction = self.position.direction_to(last_player_position).normalized()
	rotate_sprite(direction)
	velocity = direction * stats.speed
	move_and_slide(velocity)


func _finished_investigating():
	if self.position.distance_to(last_player_position) < 5:
		last_player_position = null
		return true
	return false

func rotate_sprite(direction):
	if direction.angle() < PI / 4 and direction.angle() > -PI / 4:
		sprite.play("walk_right")
		rotate_weapon(Direction.RIGHT)
	if direction.angle() < (-PI / 4) * 3 or direction.angle() > (PI / 4) * 3:
		sprite.play("walk_left")
		rotate_weapon(Direction.LEFT)
	if direction.angle() < (-PI / 4)  and direction.angle() > (-PI / 4) * 3:
		sprite.play("walk_back")
		rotate_weapon(Direction.UP)
	if direction.angle() < (PI / 4) * 3 and direction.angle() > (PI / 4):
		sprite.play("walk_front")
		rotate_weapon(Direction.DOWN)


func rotate_weapon(direction: int):
	if weapon != null:
		match direction:
			Direction.UP:
				weapon.rotation_degrees = 180
			Direction.RIGHT:
				weapon.rotation_degrees = 270
			Direction.DOWN:
				weapon.rotation_degrees = 0
			Direction.LEFT:
				weapon.rotation_degrees = 90

func _should_chase_player():
	if player != null:
		return true
	else:
		return false
		

func _should_investigate():
	if last_player_position != null:
		return true
	else:
		return false
	

func player_spotted(last_position):
	if self.name == "Cat":
		last_player_position = last_position


func _on_ObservingArea_body_entered(body):
	player = body
	
	
func _on_ObservingArea_body_exited(body):
	player = null
