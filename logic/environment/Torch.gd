extends Node2D


export var charge_per_tick := 10


onready var charging_area := $TorchArea/ChargingArea
onready var charge_timer := $ChargeTimer

func _ready():
	pass # Replace with function body.


func _on_TorchArea_body_entered(body):
	if body.name == "Player":
		charge_timer.start()
		get_tree().call_group("Player", "charging", charge_per_tick)


func _on_TorchArea_body_exited(body):
	if body.name == "Player":
		charge_timer.stop()


func _on_ChargeTimer_timeout():
	get_tree().call_group("Player", "charging", charge_per_tick)
