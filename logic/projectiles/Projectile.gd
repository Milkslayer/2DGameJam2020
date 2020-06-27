extends Area2D

class_name Projectile

export var speed = 150
export var damage = 20
var velocity := Vector2()

var hit_effect_type = null

enum HitEffect{
	LIGHT = 0,
	FIRE = 1
}

signal projectile_hit(hit_position, body_hit, projectile_type)
signal hit_fire_place(body_hit)
signal enemy_hit(node, damage)

func _ready():
	self.connect("projectile_hit", get_tree().get_root().get_node("Game"), "generate_hit_effect")
	self.connect("hit_fire_place", get_tree().get_root().get_node("Game"), "activate_fire_place")
	
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		self.connect("enemy_hit", enemy, "_taking_damage")

	
	
func _process(delta):
	if not $OnScreen.is_on_screen():
		queue_free()


func _physics_process(delta):
	velocity = velocity.normalized()
	position += velocity * speed * delta
	
	
func _set_damage(new_damage:int):
	self.damage = new_damage

	
func set_direction_and_starting_position(point_direction: Vector2, starting_position: Vector2):
	rotation = position.direction_to(point_direction).angle() - PI / 2
	velocity = point_direction
	global_position = starting_position


func init(effect_type):
	hit_effect_type = effect_type


func _on_Projectile_area_entered(area):
	emit_signal("projectile_hit", position, area, hit_effect_type)
	
	if area.name == "EnemyHitbox":
		emit_signal("enemy_hit", area.get_parent(), damage)
	
	queue_free()


func _on_Projectile_body_entered(body):
	if body.name == "Arena":
		emit_signal("projectile_hit", position, body, hit_effect_type)

	if body.name == "FirePlaceStaticBody":
		if hit_effect_type == HitEffect.FIRE:
			emit_signal("hit_fire_place", body)
	
	queue_free()
