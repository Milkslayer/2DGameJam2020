extends Stats

class_name PlayerStats


const MIN_CHARGE: int = 0
const MAX_CHARGE: int = 100
 
const MIN_FIREBALLS = 0
const MAX_FIREBALLS = 5

const ERROR_INVALID_FIREBALLS = "PlayerStats: FIREBALLS must be between %d and %d." % [MIN_FIREBALLS, MAX_FIREBALLS]

var charge: = 0
var count_fireballs: = 0

# Called when the node enters the scene tree for the first time.
func _initialize_player_stats(health_points: int, movement_speed: int, damage_per_hit: int, starting_fireballs: int):
	._initialize_stats(health_points, movement_speed, damage_per_hit)
	
	if MIN_FIREBALLS > starting_fireballs or starting_fireballs > MAX_FIREBALLS:
		push_error(ERROR_INVALID_FIREBALLS)
			
	self.count_fireballs = starting_fireballs


func _apply_charge(charge):
	if (self.charge + charge) < MAX_CHARGE:
		self.charge += charge
	elif self.charge != MAX_CHARGE:
		var remaining_charge = MAX_CHARGE - self.charge
		self.charge += remaining_charge

func _add_fireball():
	if count_fireballs != MAX_FIREBALLS:
		count_fireballs += 1


func _check_charge():
	if self.charge == 100:
		self.charge = 0
		self._add_fireball()


func _remove_fireball():
	if count_fireballs != MIN_FIREBALLS:
		count_fireballs -= 1


