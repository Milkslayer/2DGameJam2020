extends StateMachine

class_name PlayerStateMachine

var previous_position : Vector2

var is_attacking = false

var incoming_damage: int
var incoming_health: int
var incoming_charge: int


func _ready():
	add_state("idle")
	add_state("moving")
	add_state("attacking")
	add_state("taking_damage")
	add_state("healing")
	add_state("charging")
	add_state("dead")
	call_deferred("_set_state", states.idle)

func _state_logic(delta):
	if state != states.dead:
		previous_position = parent.position
		parent._get_action_input()
		parent._get_movement_input()
	
	match state:
		states.taking_damage:
			parent.animations.play("TakeDamage")
			parent.stats._remove_health(incoming_damage)
			parent.emit_signal("health_changed", parent.stats.health)
			parent.hit_sound.play()
			incoming_damage = 0
		states.healing:
			parent.animations.play("Heal")	
			parent.stats._apply_health(incoming_health)
			parent.emit_signal("health_changed", parent.stats.health)			
			incoming_health = 0
		states.charging:
			parent.animations.play("Charge")
			parent.stats._apply_charge(incoming_charge)
			parent.emit_signal("charge_changed", parent.stats.charge)	
			if parent.stats.count_fireballs != parent.stats.MAX_FIREBALLS:
				if parent.stats._check_charge():
					parent.emit_signal("charge_changed", parent.stats.charge)	
					parent.stats._add_fireball()
					parent.emit_signal("fireball_count_changed", parent.stats.count_fireballs)				
			incoming_charge = 0
		states.dead:
			pass #END GAME
	

func _get_transition(delta):
	match state:
		states.taking_damage:
			if parent.should_die():
				parent.sprite.stop()
				parent.animations.play("Die")
				parent.emit_signal("player_died")
				return states.dead
			if incoming_damage == 0 and previous_position != parent.position:
				return states.moving
			if incoming_damage == 0 and previous_position == parent.position:
				return states.idle
		states.idle:
			if is_attacking:
				return states.attacking
			if incoming_damage != 0:
				return states.taking_damage
			if incoming_health != 0:
				return states.healing
			if incoming_charge != 0:
				return states.charging
			if previous_position != parent.position:
				return states.moving
		states.moving:
			if is_attacking:
				return states.attacking
			if incoming_damage != 0:
				return states.taking_damage
			if incoming_health != 0:
				return states.healing
			if incoming_charge != 0:
				return states.charging
			if previous_position == parent.position:
				return states.idle
		states.attacking:
			if incoming_damage != 0:
					return states.taking_damage
			if incoming_health != 0:
				return states.healing
			if incoming_charge != 0:
				return states.charging
			if not is_attacking:
				if previous_position != parent.position:
					return states.moving
				if previous_position == parent.position:
					return states.idle
		states.healing:
			if is_attacking:
				return states.attacking
			if incoming_health == 0 and previous_position != parent.position:
				return states.moving
			if incoming_health == 0 and previous_position == parent.position:
				return states.idle
		states.charging:
			if is_attacking:
				return states.attacking
			if incoming_charge == 0 and previous_position != parent.position:
				return states.moving
			if incoming_charge == 0 and previous_position == parent.position:
				return states.idle
			
	return null


func _enter_state(new_state, old_state):
	pass
	
	
func _exit_state(old_state, new_state):
	pass
	

func taking_damage(damage: int):
	incoming_damage = damage
	
	
func healing(health_points: int):
	incoming_health = health_points
	

func charging(charge_points: int):
	incoming_charge = charge_points


func handle_action_input(event):
	if state != states.dead:
		var mouse_pos = get_viewport().get_mouse_position()
		if event.is_action_pressed("fire_primary"):
			parent.attack_timer.start()
			is_attacking = true
			parent.shoot_light(mouse_pos)
		if event.is_action_pressed("fire_secondary"):
			if parent.stats.count_fireballs > 0:
				parent.attack_timer.start()
				is_attacking = true
				parent.shoot_fire(mouse_pos)
				parent.stats._remove_fireball()
				parent.emit_signal("fireball_count_changed", parent.stats.count_fireballs)			
				if parent.stats.charge == parent.stats.MAX_CHARGE:
					if parent.stats._check_charge():
						parent.emit_signal("charge_changed", parent.stats.charge)	
						parent.stats._add_fireball()
						parent.emit_signal("fireball_count_changed", parent.stats.count_fireballs)				
				
					


func _on_AttackTimer_timeout():
	is_attacking = false
