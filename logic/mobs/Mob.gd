extends KinematicBody2D

class_name Mob

var stats
var state_machine_script = preload("res://logic/mobs/MobStateMachine.gd")
var state_machine
var attack_timer
var wait_timeout
var rng: RandomNumberGenerator
var roam_area

export var health = 0
export var damage = 0
export var speed = 0
export var difficulty = 0

onready var sprite := $MobSprite
onready var animations := $Animations
onready var hitbox := $EnemyHitbox/EnemyHitboxCollision
onready var observing_area := $ObservingArea/ObservingAreaCollision
onready var hp_bar: ProgressBar = $HealthBar
onready var sfx_hit = $SFXHit

var despawn_timer: Timer

var velocity = Vector2()
var weapon = null
var label = null

var player
var last_player_position
var destination

enum Direction{
	UP = 0,
	RIGHT = 1, 
	DOWN = 2,
	LEFT = 3
}

signal despawn(position)
signal taking_damage(damage)
signal enemy_died(enemy)

func _ready():
	stats = MobStats.new()
	
	state_machine = Node.new()
	state_machine.set_script(state_machine_script)
	state_machine.name = "MobStateMachine"
	self.connect("despawn", get_tree().get_root().get_node("Game"), "generate_despawn_effect")
	self.connect("taking_damage", state_machine, "taking_damage")
	self.connect("enemy_died", get_tree().get_root().get_node("Game"), "enemy_died")
	add_child(state_machine)
	
	stats._initialize_mob_stats(2, health, speed, damage)
		
	if self.name != "Cat":
		if get_node("Weapon") != null:
			weapon = get_node("Weapon")
			weapon.get_child(0).set_damage(stats.damage)
	if self.name == "Cat":
		attack_timer = get_node("AttackTimer")
	label = get_node("Label")

	rng = RandomNumberGenerator.new()
	rng.randomize()
	init_timers()
	
	hp_bar.percent_visible = false
	hp_bar.value = 100
	

	self.emit_signal("despawn", self.position)

func _process(delta):
	if get_tree().get_root().get_node("Game").DEBUG:
		var state
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
			state_machine.states.taking_damage:
				state = "TAKING_DAMAGE"
			state_machine.states.dead:
				state = "DEAD"

		var text = "STATE: %s\nHEALTH: %d\nDMG_PER_HIT: %d\nSPEED: %d\nDIFFICULTY: %d" % [state, stats.health, stats.damage, stats.speed, stats.difficulty]
		label.text = text
	if roam_area == null:
		roam_area = get_tree().get_root().get_node("Game").roam_area
		

func init_timers():
	despawn_timer = Timer.new()
	despawn_timer.wait_time = 0.5
	despawn_timer.one_shot = true
	despawn_timer.connect("timeout", state_machine, "should_despawn")
	wait_timeout = Timer.new()
	wait_timeout.wait_time = 1
	wait_timeout.one_shot = true
	wait_timeout.connect("timeout", state_machine, "finished_waiting")	
	add_child(despawn_timer)
	add_child(wait_timeout)
	

func _stop():
	velocity = Vector2()


func _set_state_dead():
	self.state_machine._set_state(self.state_machine.states.dead)
	

func _chase_player():
	if _should_chase_player():
		var direction = self.position.direction_to(player.position).normalized()
		rotate_sprite(direction)
		velocity = direction * stats.speed
		move_and_slide(velocity)

func _investigate_last_player_spot():
	if _should_investigate():
		var direction = self.position.direction_to(last_player_position).normalized()
		rotate_sprite(direction)
		velocity = direction * stats.speed
		move_and_slide(velocity)


func _finished_investigating():
	if self.position.distance_to(last_player_position) < 5:
		last_player_position = null
		return true
	return false


func _disable_weapon():
	if self.name != "Cat":
		if get_node("Weapon") != null:
			weapon = get_node("Weapon")
			weapon.get_child(0).disable()


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


func _get_rand_destination() -> Vector2:
	rng.randomize()
	return Vector2(rng.randi_range(roam_area[0].x, roam_area[1].x), rng.randi_range(roam_area[0].y, roam_area[1].y))


func _patrol():
	if destination != null:
		var direction = self.position.direction_to(destination).normalized()
		rotate_sprite(direction)
		velocity = direction * stats.speed
		move_and_slide(velocity)
		


func _arrived_at_destination():
	if destination != null:
		if self.position.distance_to(destination) < 15:
			destination = null
			return true
	return false

func _should_chase_player():
	if player != null:
		last_player_position = null
		return true
	else:
		return false
		

func _should_investigate():
	if last_player_position != null:
		return true
	else:
		return false
	
	
func _taking_damage(node, damage:int):
	if self == node:
		if state_machine.state != state_machine.states.dead:
			emit_signal("taking_damage", damage)
			


func _should_die() -> bool:
	if stats.health == 0:
		return true
	return false
	

func player_spotted(last_position):
	if self.name == "Cat":
		last_player_position = last_position


func _update_hp_bar():
	var ratio = float(stats.health) / float(stats.starting_health)
	hp_bar.value = ratio * 100


func _attack_player():
	if player != null:
		if _should_attack():
			attack_timer.start()
			get_tree().call_group("Player", "taking_damage", stats.damage)
			
			

func _should_attack():
	if player != null:
		if self.name == "Cat":
			if self.position.distance_to(player.position) < 30:
				return true
	return false


func _on_AttackTimer_timeout():
	if _should_attack():
		_attack_player()
	else:
		attack_timer.stop()


func _on_ObservingArea_body_entered(body):
	player = body
	
	
func _on_ObservingArea_body_exited(body):
	player = null

func _should_wait():
	if destination == null:
		var rand = rng.randi_range(-10, 10)
		if rand % 2 == 0 and rand > 0:
			return true
	return false
