extends Node2D

export var light_hit_effect: PackedScene
export var fire_hit_effect: PackedScene
export var easy_enemy: PackedScene
export var average_enemy: PackedScene
export var hard_enemy: PackedScene

enum HIT_EFFECT{
	LIGHT = 0,
	FIRE = 1
}


func _ready():
	pass


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

func activate_fire_place(body):
	body.get_parent()._activate()
