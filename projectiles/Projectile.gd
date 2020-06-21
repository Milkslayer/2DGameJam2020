extends Area2D

class_name Projectile

export var speed = 150
export var damage = 20
var velocity := Vector2()

var hit_effect_type = null

enum HIT_EFFECT{
	LIGHT = 0,
	FIRE = 1
}

signal projectile_hit(hit_position, body_hit, projectile_type)


func _ready():
	self.connect("projectile_hit", get_tree().get_root().get_node("Game"), "generate_hit_effect")


func _process(delta):
	if not $OnScreen.is_on_screen():
		queue_free()


func _physics_process(delta):
	velocity = velocity.normalized()
	position += velocity * speed * delta
	
	
func set_direction_and_starting_position(point_direction: Vector2, starting_position: Vector2):
	rotation = position.direction_to(point_direction).angle() - PI / 2
	velocity = point_direction
	position = starting_position


func init(effect_type: int):
	hit_effect_type = effect_type


func _on_Projectile_body_entered(body):
	emit_signal("projectile_hit", position, body, hit_effect_type)
	queue_free()
