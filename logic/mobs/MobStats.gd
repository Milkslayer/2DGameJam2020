extends "res://logic/Stats.gd"

class_name MobStats

const MIN_DIFFICULTY_LEVEL: int = 1
const MAX_DIFFICULTY_LEVEL: int = 10
 
const ERROR_INVALID_DIFFICULTY_LEVEL = "MobStats: DIFFICULTY LEVEL must be between %d and %d." % [MIN_DIFFICULTY_LEVEL, MAX_DIFFICULTY_LEVEL]

export var difficulty := 0


func _initialize_mob_stats(difficulty_level: int, health_points: int, movement_speed: int, damage_per_hit: int):
	._initialize_stats(health_points, movement_speed, damage_per_hit)
	
	if MIN_DIFFICULTY_LEVEL > difficulty_level or difficulty_level > MAX_DIFFICULTY_LEVEL:
		push_error(ERROR_INVALID_DIFFICULTY_LEVEL)
			
	self.difficulty = difficulty_level
	set_difficulty_settings()
	
func set_difficulty_settings():
	var c = self.difficulty / PI
	if c < 0:
		push_error("MobStats: coefficient is less than 0. Mob settings will be negative")
	
	self.health *= c 
	self.damage *= c 
	self.speed *= c 
