extends KinematicBody2D

class_name Mob

var velocity = Vector2()
export var speed := 0
export var damage := 0
export var difficulty := 0
export var health := 0

func _ready():
	
	if [speed, damage, difficulty, health].has(0):
		push_error("MOB: Base values cannot be 0")
	
	
func _attack():
	pass
	

func _move():
	pass
	
	
func _initialize(difficulty_level, health, movement_speed, dmg_per_hit):
	speed = movement_speed
	health = health
	damage = dmg_per_hit
	difficulty = difficulty_level
	


