extends Node2D

onready var door_sm = $DoorSM
onready var door_animation = $DoorAnimation
onready var door_collision = $DoorStaticBody/ClosedCollision
onready var tooltip = $Tooltip

signal _player_entered_area(door)
signal _player_exited_area(door)


func _ready():
	$Tooltip.visible = false



func _on_AreaDoor_area_entered(area):
	if area.name == "PlayerHitbox":
		$Tooltip.visible = true
		emit_signal("_player_entered_area", self)


func _on_AreaDoor_area_exited(area):
	if area.name == "PlayerHitbox":
		$Tooltip.visible = false
		emit_signal("_player_exited_area", self)

func _on_Player__interact_with_door(door):
	if door == self:
		if $DoorSM.state == $DoorSM.states.open:
			$DoorSM.close_door()
		if $DoorSM.state == $DoorSM.states.closed:
			$DoorSM.open_door()
