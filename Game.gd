extends Node2D

export var light_hit_effect: PackedScene
export var fire_hit_effect: PackedScene

enum HIT_EFFECT{
	LIGHT = 0,
	FIRE = 1
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	connect("projectile_hit", self, "generate_hit_effect", [hit_position, projectile_type])


func generate_hit_effect(hit_position: Vector2, body, type):
	match type:
		HIT_EFFECT.LIGHT:
			var temp = light_hit_effect.instance()
			temp.position = hit_position
			add_child(temp)
		HIT_EFFECT.FIRE:
			var temp = fire_hit_effect.instance()
			temp.position = hit_position
			add_child(temp)
