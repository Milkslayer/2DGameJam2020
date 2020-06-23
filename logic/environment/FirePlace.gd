extends Node2D

export var heal_per_tick = 5
export var active_healing_time = 5


onready var fire_light := $FireLight
onready var particles_fire := $FireParticles
onready var particles_smoke := $SmokeParticles
onready var sprite := $FirePlaceSprite
onready var healing_area = $FirePlaceArea/HealingArea
onready var healing_timer = $HealingTimer
onready var active_timer = $ActiveTimer



enum States{
	INACTIVE = 0,
	ACTIVE = 1,
}


func _ready():
	set_state(States.INACTIVE)
	active_timer.wait_time = active_healing_time


func set_state(state):
	if state == States.INACTIVE:
		sprite.play("inactive")
		fire_light.energy = 0.5
		particles_fire.emitting = false
		particles_smoke.emitting = true
		healing_area.set_deferred("disabled", true)
	if state == States.ACTIVE:
		sprite.play("active")
		fire_light.energy = 1
		particles_fire.emitting = true
		particles_smoke.emitting = false
		healing_area.set_deferred("disabled", false)

func _activate():
	active_timer.start()
	set_state(States.ACTIVE)


func _on_FirePlaceArea_body_entered(body):
	if body.name == "Player":
		healing_timer.start()
		get_tree().call_group("Player", "healing", heal_per_tick)


func _on_FirePlaceArea_body_exited(body):
	if body.name == "Player":
		healing_timer.stop()
	
	
func _on_HealingTimer_timeout():
	get_tree().call_group("Player", "healing", heal_per_tick)


func _on_ActiveTimer_timeout():
	set_state(States.INACTIVE)
