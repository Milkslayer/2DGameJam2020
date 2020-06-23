extends KinematicBody2D

class_name Mob

var stats
var state_machine_script = preload("res://logic/mobs/MobStateMachine.gd")
var state_machine


export var health = 0
export var damage = 0
export var speed = 0
export var difficulty = 0
export var weapon_type : PackedScene



onready var sprite = $MobSprite

var velocity = Vector2()

var player

func _ready():
	stats = MobStats.new()
	
	state_machine = Node.new()
	state_machine.set_script(state_machine_script)
	state_machine.name = "MobStateMachine"
	add_child(state_machine)
	
	stats._initialize_mob_stats(difficulty, health, speed, damage)
	

func _stop():
	velocity = Vector2()


func _chase_player():
	if _should_chase_player():
		var direction = self.position.direction_to(player.position).normalized()
		rotate_sprite(direction)
		velocity = direction * stats.speed
		move_and_slide(velocity)


func rotate_sprite(direction):
	if direction.angle() < PI / 4 and direction.angle() > -PI / 4:
		sprite.play("walk_right")
	if direction.angle() < (-PI / 4) * 3 or direction.angle() > (PI / 4) * 3:
		sprite.play("walk_left")
	if direction.angle() < (-PI / 4)  and direction.angle() > (-PI / 4) * 3:
		sprite.play("walk_back")
	if direction.angle() < (PI / 4) * 3 and direction.angle() > (PI / 4):
		sprite.play("walk_front")


func _should_chase_player():
	if player != null:
		return true
	else:
		return false
	
# EVENTS
func _on_ObservingArea_body_entered(body):
	player = body
	
	
func _on_ObservingArea_body_exited(body):
	player = null
