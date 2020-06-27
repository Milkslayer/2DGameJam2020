extends "res://logic/StateMachine.gd"

class_name MobStateMachine


var should_despawn = false
var incoming_damage := 0
var is_waiting = false

func _ready():
	add_state("idle")
	add_state("chasing")
	add_state("attacking")
	add_state("patrolling")
	add_state("investigating")
	add_state("taking_damage")
	add_state("dead")
	call_deferred("_set_state", states.idle)


func _state_logic(delta):
	match state:
		states.dead:
			if should_despawn:
				parent.emit_signal("despawn", parent.position)
				parent.queue_free()
				parent.emit_signal("enemy_died", parent)				
		states.taking_damage:
			parent.animations.play("TakeDamage")
			parent.stats._remove_health(incoming_damage)
			parent._update_hp_bar()
			parent.sfx_hit.play()
			incoming_damage = 0
		states.idle:
			parent._stop()
		states.chasing:
			parent._chase_player()
		states.investigating:
			parent._investigate_last_player_spot()
		states.patrolling:
			parent._patrol()


func _get_transition(delta):
	match state:
		states.taking_damage:
			if parent._should_die():
				return states.dead
			if incoming_damage == 0 and parent._should_chase_player():
				return states.chasing
			if incoming_damage == 0 and not parent._should_chase_player():
				if parent._should_wait():
					return states.idle
				return states.patrolling
		states.attacking:
			if not parent._should_attack() and parent._should_chase_player():
				return states.chasing
			if not parent._should_chase_player():
				return states.idle
		states.idle:
			if incoming_damage != 0:
				return states.taking_damage
			if parent._should_chase_player():
				return states.chasing
			if parent._should_investigate():
				return states.investigating
			if not is_waiting:
				return states.patrolling
		states.chasing:
			if incoming_damage != 0:
				return states.taking_damage
			if parent._should_attack():
				return states.attacking
			if not parent._should_chase_player():
				if parent._should_wait():
					return states.idle
				return states.patrolling
		states.investigating:
			if incoming_damage != 0:
				return states.taking_damage
			if parent._should_chase_player():
				return states.chasing
			if parent._finished_investigating():
				return states.idle
		states.patrolling:
			if incoming_damage != 0:
				return states.taking_damage
			if parent._should_chase_player():
				return states.chasing
			if parent._should_investigate():
				return states.investigating
			if parent._arrived_at_destination():
				return states.idle
				

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.sprite.stop()
			parent.wait_timeout.wait_time = parent.rng.randf_range(1, 4)
			parent.wait_timeout.start()
			is_waiting = true
		states.dead:
			parent.sprite.stop()
			parent.animations.play("Die")
			parent.hitbox.set_deferred("disabled", true)
			parent.call_deferred("_disable_weapon")
			parent.observing_area.set_deferred("disabled", true)
			parent.despawn_timer.start()
		states.attacking:
			parent._attack_player()
		states.patrolling:
			if parent.roam_area != null:
				parent.destination = parent._get_rand_destination()


func _exit_state(old_state, new_state):
	pass


func taking_damage(damage: int):
	incoming_damage = damage


func should_despawn():
	should_despawn = true

func finished_waiting():
	is_waiting = false
