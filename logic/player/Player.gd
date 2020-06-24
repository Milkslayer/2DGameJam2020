extends KinematicBody2D

export var health = 0
export var damage = 0
export var speed = 0
export var starting_fire_shots := 5

onready var pointer := $Pointer
onready var animations := $Animations
onready var sprite := $PlayerSprite
onready var label := $Label
onready var attack_timer := $AttackTimer
onready var light_projectile = load("res://projectiles/LightProjectile.tscn")
onready var fire_projectile = load("res://projectiles/FireProjectile.tscn")
var velocity = Vector2()


var stats
var state_machine_script = preload("res://logic/player/PlayerStateMachine.gd")
var state_machine 

signal action_input_detected(event)
signal taking_damage(damage)
signal healing(health_points)
signal charging(charge_points)

func _ready():
	stats = PlayerStats.new()
	stats._initialize_player_stats(health, speed, damage, starting_fire_shots)
	
	state_machine = Node.new()
	state_machine.set_script(state_machine_script)
	state_machine.name = "PlayerStateMachine"
	add_child(state_machine)
		
	sprite.play("normal_stand_front")
	
	self.connect("action_input_detected", state_machine, "handle_action_input")
	self.connect("taking_damage", state_machine, "taking_damage")
	self.connect("healing", state_machine, "healing")
	self.connect("charging", state_machine, "charging")
	attack_timer.connect("timeout", state_machine, "_on_AttackTimer_timeout")

func _process(delta):
	if get_tree().get_root().get_node("Game").DEBUG:
		var state
		match state_machine.state:
			state_machine.states.idle:
				state = "IDLE"
			state_machine.states.moving:
				state = "MOVING"
			state_machine.states.attacking:
				state = "ATTACKING"
			state_machine.states.taking_damage:
				state = "TAKING DAMAGE"
			state_machine.states.healing:
				state = "HEALING"
			state_machine.states.charging:
				state = "CHARGING"
			state_machine.states.dead:
				state = "DEAD"
		
		var text = "STATE: %s\nHEALTH: %d\nFIREBALLS: %d\nCHARGE: %d" % [state, stats.health, stats.count_fireballs, stats.charge]
		label.text = text

func _unhandled_input(event):
	emit_signal("action_input_detected", event)
		


func shoot_light(point_direction: Vector2):
	var direction = (point_direction - position).normalized()
	var shot = light_projectile.instance()
	shot.set_direction_and_starting_position(direction, position)
	get_parent().add_child(shot)


func shoot_fire(point_direction: Vector2):
	var direction = (point_direction - position).normalized()
	var shot = fire_projectile.instance()
	shot.set_direction_and_starting_position(direction, position)
	get_parent().add_child(shot)


func rotate_pointer(point_direction: Vector2):
	pointer.rotation = self.position.direction_to(point_direction).angle() - PI / 2


func rotate_sprite(point_direction: Vector2):
	var direction = (point_direction - position).normalized()
	
	if direction.angle() < PI / 4 and direction.angle() > -PI / 4:
		sprite.flip_h = true
		sprite.play("normal_walk")
	if direction.angle() < (-PI / 4) * 3 or direction.angle() > (PI / 4) * 3:
		sprite.flip_h = false
		sprite.play("normal_walk")
	if direction.angle() < (-PI / 4)  and direction.angle() > (-PI / 4) * 3:
		sprite.play("normal_stand_back")
	if direction.angle() < (PI / 4) * 3 and direction.angle() > (PI / 4):
		sprite.play("normal_stand_front")


func _get_movement_input():
	var movement_h = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
	var movement_v = -int(Input.is_action_pressed("ui_up")) + int(Input.is_action_pressed("ui_down"))
	velocity.x = speed * movement_h
	velocity.y = speed * movement_v
	
	var velocity_ratio = velocity.abs().aspect()
	if velocity_ratio == 1:
		velocity /= sqrt(2)
	move_and_slide(velocity)


func _get_action_input():
	var mouse_pos = get_viewport().get_mouse_position()
	rotate_pointer(mouse_pos)
	rotate_sprite(mouse_pos)


func taking_damage(damage: int):
	if state_machine.state != state_machine.states.dead:
		emit_signal("taking_damage", damage)


func healing(healt_points: int):
	if stats.health != stats.MAX_BASE_HEALTH and state_machine.state != state_machine.states.dead:
		emit_signal("healing", healt_points)

	
func charging(charge_points: int):
	if stats.charge != stats.MAX_CHARGE and state_machine.state != state_machine.states.dead:
		emit_signal("charging", charge_points)


func should_die() -> bool:
	if stats.health == 0:
		return true
	return false
