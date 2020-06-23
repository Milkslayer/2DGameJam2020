extends Node

class_name Stats

const MIN_BASE_HEALTH: int = 50
const MAX_BASE_HEALTH: int = 100
const MIN_BASE_DAMAGE: int = 1
const MAX_BASE_DAMAGE: int = 10
const MIN_BASE_SPEED: int = 150
const MAX_BASE_SPEED: int = 200

const ERROR_INVALID_BASE_HEALTH = "Stats: Base HEALTH must be between %d and %d." % [MIN_BASE_HEALTH, MAX_BASE_HEALTH]
const ERROR_INVALID_BASE_DAMAGE = "Stats: Base DAMAGE must be between %d and %d." % [MIN_BASE_DAMAGE, MAX_BASE_DAMAGE]
const ERROR_INVALID_BASE_SPEED = "Stats: Base SPEED must be between %d and %d." % [MIN_BASE_SPEED, MAX_BASE_SPEED]


var speed := 0
var damage := 0
var health := 0


func _ready():
	pass # Replace with function body.

func _initialize_stats(health_points: int, movement_speed: int, damage_per_hit: int):
	if MIN_BASE_HEALTH > health_points or health_points > MAX_BASE_HEALTH:
		push_error(ERROR_INVALID_BASE_HEALTH)
	if MIN_BASE_DAMAGE > damage_per_hit or damage_per_hit > MAX_BASE_DAMAGE:
		push_error(ERROR_INVALID_BASE_DAMAGE)
	if MIN_BASE_SPEED > movement_speed or movement_speed > MAX_BASE_SPEED:
		push_error(ERROR_INVALID_BASE_SPEED)
	
	self.health = health_points
	self.speed = movement_speed
	self.damage = damage_per_hit
