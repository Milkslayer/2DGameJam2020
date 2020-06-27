extends Control


onready var health_bar := $HealthBar
onready var charge_bar := $ChargeBar
onready var fireball_counter := $FireBallCounter


func _ready():
	pass

func _initialize_player_stats(max_health:int, max_charge:int, max_fireballs:int):
	health_bar._initialize(max_health)
	charge_bar._initialize(max_charge)
	fireball_counter._initialize(max_fireballs)

func _update_health_bar(new_health:int):
	health_bar._update_bar(new_health)
	
	
func _update_charge_bar(new_charge:int):
	charge_bar._update_bar(new_charge)
	
	
func _update_fireball_counter(new_fireball_count:int):
	fireball_counter._update_counter(new_fireball_count)
