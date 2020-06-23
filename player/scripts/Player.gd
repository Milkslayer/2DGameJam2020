extends KinematicBody2D

# CONST
const MAX_FIRE_SHOTS = 5
const PLAYER_GLOW_COLOR_HEX = "a4fbff"
# CONST END

# EXPORT VAR
export var speed = 150
export var health = 100
# EXPORT END
# ONREADY VAR
onready var pointer := $Pointer
onready var animations := $Animations
onready var light_projectile = load("res://projectiles/LightProjectile.tscn")
onready var fire_projectile = load("res://projectiles/FireProjectile.tscn")
# ONREADY VAR END
# VARIABLES
var velocity = Vector2()
var can_interact_with_door = false
var _door = null
# VARIABLES END
# SIGNALS
signal _interact_with_door(door)

# SIGNALS END
func _ready():
	$PlayerSprite.play("normal_stand_front")
	

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	rotate_pointer(mouse_pos)
	rotate_sprite(mouse_pos)
	
	
func _physics_process(delta):
	_get_input()
	move_and_slide(velocity)
	
	
func _unhandled_input(event):
	var mouse_pos = get_viewport().get_mouse_position()
	if event.is_action_pressed("fire_primary"):
		 shoot_light(mouse_pos)
	if event.is_action_pressed("fire_secondary"):
		 shoot_fire(mouse_pos)


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
		$PlayerSprite.flip_h = true
		$PlayerSprite.play("normal_walk")
	if direction.angle() < (-PI / 4) * 3 or direction.angle() > (PI / 4) * 3:
		$PlayerSprite.flip_h = false
		$PlayerSprite.play("normal_walk")
	if direction.angle() < (-PI / 4)  and direction.angle() > (-PI / 4) * 3:
		$PlayerSprite.play("normal_stand_back")
	if direction.angle() < (PI / 4) * 3 and direction.angle() > (PI / 4):
		$PlayerSprite.play("normal_stand_front")


func _get_input():
	var movement_h = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
	var movement_v = -int(Input.is_action_pressed("ui_up")) + int(Input.is_action_pressed("ui_down"))
	velocity.x = speed * movement_h
	velocity.y = speed * movement_v
	
	var velocity_ratio = velocity.abs().aspect()
	if velocity_ratio == 1:
		velocity /= sqrt(2)


func take_damage(damage: int):
	animations.play("TakeDamage")
	print("Taking %d damage" % damage)
