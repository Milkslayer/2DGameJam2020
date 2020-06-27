extends Node2D

enum Difficulty {
	EASY = 0,
	MEDIUM = 1,
	HARD = 2
}

enum HIT_EFFECT{
	LIGHT = 0,
	FIRE = 1
}

var DEBUG = true

export var light_hit_effect: PackedScene
export var fire_hit_effect: PackedScene
export var enemy_despawn_effect: PackedScene
export var player: PackedScene

onready var roam_area_collision_shape = $RoamArea/RoamAreaCollision
onready var y_sort := $YSort
onready var enemy_killed_timer := $EnemyKilledTimer
onready var start_timer = $StartTimer
onready var reset_timer = $ResetTimer
onready var win_timeout = $WinTimeout
onready var roam_area = get_roam_area()
onready var enemy_spawner := $EnemySpawner

onready var intro_camera = $IntroScreen
onready var game_camera = $GameScreen
onready var fire_place = $IntroPlaceholders/FirePlace
onready var hud = $GUICover/HUD
onready var gui = $GUICover/GUI
onready var game_music = $GameMusic
onready var win_music = $WinMusic
onready var fire_hit_sfx = $SFXFireExplosion
onready var light_hit_sfx = $SFXLightExplosion

var intro_fire = false

var enemy_girl = preload("res://mobs/ChildGirl.tscn")
var enemy_cat = preload("res://mobs/Cat.tscn")
var enemy_boy = preload("res://mobs/ChildBoy.tscn")
var spawner = preload("res://logic/EnemySpawner.gd")

var enemy_types = {"defaults": [enemy_girl, enemy_boy], "special":enemy_cat}

var rng : RandomNumberGenerator

var game_difficulty
var player_instance

signal _gui_menu_opened

func _ready():
	rng = RandomNumberGenerator.new()
	self.connect("_gui_menu_opened", get_node("GUICover/GUI"), "_menu_opened")
	_init_intro_menu()
#	init_enemy_spawner(Difficulty.EASY)
	
func _process(delta):
	if not intro_fire:
		fire_place.set_state(1)
		intro_fire = true
		

func _init_intro_menu():
	self.emit_signal("_gui_menu_opened")
	intro_camera.make_current()
	hud.visible = false
	gui.visible = true
	fire_place.visible = true


func start_game(difficulty):
	self.game_difficulty = difficulty
	intro_camera.clear_current()
	game_camera.make_current()
	hud.visible = true
	gui.visible = false
	fire_place.visible = false
	start_timer.start()
	fire_place.set_state(0)
	init_player()
	
	

func init_player():
	self.player_instance = self.player.instance()
	self.player_instance.position = roam_area_collision_shape.position
	y_sort.add_child(self.player_instance)

func init_enemy_spawner(difficulty):
	enemy_spawner._initialize(y_sort, rng, roam_area, difficulty, enemy_types)
	start_new_wave()

func start_new_wave():
	enemy_spawner._start_wave()



func get_roam_area():
	var origin = roam_area_collision_shape.position
	var dimensions_halved = roam_area_collision_shape.shape.extents
	var roam_ctl = origin - dimensions_halved
	var roam_cbr = origin + dimensions_halved
	
	return [roam_ctl, roam_cbr]


func generate_despawn_effect(position: Vector2):
	var temp = enemy_despawn_effect.instance()
	temp.position = position
	call_deferred("add_child", temp)


func generate_hit_effect(hit_position: Vector2, body, type):
	match type:
		HIT_EFFECT.LIGHT:
			var temp = light_hit_effect.instance()
			temp.position = hit_position
			add_child(temp)
			light_hit_sfx.play()
		HIT_EFFECT.FIRE:
			var temp = fire_hit_effect.instance()
			temp.position = hit_position
			add_child(temp)
			fire_hit_sfx.play()


func activate_fire_place(body):
	body.get_parent()._activate()


func enemy_died(enemy):
	enemy_killed_timer.start()


func player_died():
	reset_timer.start()
	game_music.stop()

func _on_EnemyKilledTimer_timeout():
	if enemy_spawner._check_state():
		if not enemy_spawner._end_wave():
			win_timeout.start()
			game_music.stop()
			win_music.play()

func _on_StartTimer_timeout():
	init_enemy_spawner(self.game_difficulty)
	game_music.play()

func _on_ResetTimer_timeout():
	end_game()

func end_game():
	self.player_instance.queue_free()	
	enemy_spawner._reset()
	enemy_spawner.queue_free()
	enemy_spawner = Node.new()
	enemy_spawner.set_script(spawner)
	add_child(enemy_spawner)
	intro_fire = false
	_init_intro_menu()


func _on_WinTimeout_timeout():
	win_music.stop()
	end_game()
