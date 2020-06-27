extends Node2D


export var charge_per_tick := 10


onready var charging_area := $TorchArea/ChargingArea
onready var charge_timer := $ChargeTimer
onready var fire_particles := $FireParticles
onready var torch_light := $TorchLight


func _ready():
	_turn_on()


func _turn_on():
	charging_area.set_deferred("disabled", false)
	torch_light.enabled = true
	fire_particles.emitting = true
	
	
func _turn_off():
	charging_area.set_deferred("disabled", true)
	torch_light.enabled = false
	fire_particles.emitting = false
	


func _on_TorchArea_body_entered(body):
	if body.name == "Player":
		charge_timer.start()
		get_tree().call_group("Player", "charging", charge_per_tick)


func _on_TorchArea_body_exited(body):
	if body.name == "Player":
		charge_timer.stop()


func _on_ChargeTimer_timeout():
	get_tree().call_group("Player", "charging", charge_per_tick)
