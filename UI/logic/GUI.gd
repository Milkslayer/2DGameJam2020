extends Control


onready var instructions = $HelpInstructions
onready var click_sound = $UiClickSound
onready var lobby_music = $Lobby


signal start_game(setting)
var help_is_open = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("start_game", get_tree().get_root().get_node("Game"), "start_game")
	instructions.visible = false

func _menu_opened():
	lobby_music.play()
	

func _on_Easy_pressed():
	self.emit_signal("start_game", 0)
	click_sound.play()
	lobby_music.stop()

func _on_Medium_pressed():
	self.emit_signal("start_game", 1)
	click_sound.play()
	lobby_music.stop()
	

func _on_Hard_pressed():
	self.emit_signal("start_game", 2)
	click_sound.play()
	lobby_music.stop()


func _on_Help_pressed():
	if not help_is_open:
		instructions.visible = true
		help_is_open = true
	else:
		instructions.visible = false
		help_is_open = false
	click_sound.play()


func _on_Lobby_finished():
	lobby_music.play()


