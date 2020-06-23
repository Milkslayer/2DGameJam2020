extends Node2D

export var damage_per_tick = 5

onready var timer = $DamageTimer
onready var light = $AreaOfEffect/Light
onready var aoe_collision = $AreaOfEffect/AreaOfEffectCollision

var player_in_range := false


func _ready():
	turn_on()


func turn_off():
	light.enabled = false	
	aoe_collision.disabled = true

func turn_on():
	light.enabled = true
	aoe_collision.disabled = false
	


func _on_DamageTimer_timeout():
	get_tree().call_group("Player", "take_damage", damage_per_tick)


func _on_AreaOfEffect_area_entered(area):
	if area.name == "PlayerHitbox":
		player_in_range = true
		timer.start()
		get_tree().call_group("Player", "take_damage", damage_per_tick)


func _on_AreaOfEffect_area_exited(area):
	if area.name == "PlayerHitbox":
		player_in_range = false
		timer.stop()
