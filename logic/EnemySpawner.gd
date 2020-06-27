extends Node

class_name EnemySpawner

enum Difficulty {
	EASY = 0,
	MEDIUM = 1,
	HARD = 2
}

var container:YSort
var difficulty
var starting_enemy_count := 0
var max_enemy_count := 0
var spawn_area := [Vector2(), Vector2()]
var wave_count := 0
var max_waves := 0
var rng:RandomNumberGenerator
var enemies_to_add := 0

var enemy_types = {"default": [null, null], "special":null}

var enemies = []

signal wave_ended

func _initialize(container, rand_number_generator:RandomNumberGenerator, spawn_area, difficulty:int, enemy_types):

	connect("wave_ended", get_tree().get_root().get_node("Game"), "start_new_wave")
	self.container = container
	self.difficulty = difficulty
	self.rng = rand_number_generator
	self.spawn_area = spawn_area
	self.enemy_types = enemy_types
	match self.difficulty:
		Difficulty.EASY:
			starting_enemy_count = 2
			max_enemy_count = 6
			max_waves = 5
		Difficulty.MEDIUM:
			starting_enemy_count = 3
			max_enemy_count = 12
			max_waves = 7
		Difficulty.HARD:
			starting_enemy_count = 4
			max_enemy_count = 20
			max_waves = 12
	enemies_to_add = int(abs(max_waves - (max_enemy_count - starting_enemy_count)))
func _start_wave():
	if wave_count == max_waves:
		for i in range(starting_enemy_count):
			var enemy_instance = enemy_types.defaults[rng.randi_range(0,1)].instance()
			enemy_instance.position = get_rng_spawn_location()
			enemies.append(enemy_instance)

		match self.difficulty:
			Difficulty.EASY:
				var special_enemy = enemy_types.special.instance()
				special_enemy.position = get_rng_spawn_location()
				enemies.append(special_enemy)
			Difficulty.MEDIUM:
				for i in range(2):
					var special_enemy = enemy_types.special.instance()
					special_enemy.position = get_rng_spawn_location()
					enemies.append(special_enemy)
			Difficulty.HARD:
				for i in range(4):
					var special_enemy = enemy_types.special.instance()
					special_enemy.position = get_rng_spawn_location()
					enemies.append(special_enemy)
	elif wave_count < max_waves:
		for i in range(starting_enemy_count):
			var enemy_instance = enemy_types.defaults[rng.randi_range(0,1)].instance()
			if starting_enemy_count < max_enemy_count:
				enemy_instance.position = get_rng_spawn_location()
				enemies.append(enemy_instance)
			elif max_enemy_count - starting_enemy_count < enemies_to_add:
				enemy_instance.position = get_rng_spawn_location()
				enemies.append(enemy_instance)
			elif starting_enemy_count == max_enemy_count:
				enemy_instance.position = get_rng_spawn_location()
				enemies.append(enemy_instance)
		if starting_enemy_count < max_enemy_count:
			starting_enemy_count += enemies_to_add
		if max_enemy_count - starting_enemy_count < enemies_to_add:
			starting_enemy_count = max_enemy_count
	wave_count += 1		
#	print("Starting wave %d with %d peeps" % [wave_count, starting_enemy_count - enemies_to_add])
	add_enemies_to_game()
	
	
func _end_wave():
	if wave_count < max_waves + 1:
		enemies.clear()
		self.emit_signal("wave_ended")
		return true
	elif wave_count == max_waves + 1:
		return false
		
		
func _check_state() -> bool:
	for enemy in self.enemies:
		if is_instance_valid(enemy):
			return false
	return true

func add_enemies_to_game():
	for enemy in self.enemies:
		self.container.add_child(enemy)

func _reset():
	enemies = []
	for child in container.get_children():
		child.queue_free()

func get_rng_spawn_location():
	rng.randomize()
	return Vector2(rng.randi_range(spawn_area[0].x, spawn_area[1].x), rng.randi_range(spawn_area[0].y, spawn_area[1].y))
