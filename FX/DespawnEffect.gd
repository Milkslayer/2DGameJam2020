extends Node2D


func _ready():
	$Flash.enabled = true	
	$DustParticles.emitting = true
	$EffectTimeout.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_EffectTimeout_timeout():
	$DustParticles.emitting = false
	$Flash.enabled = false
	queue_free()
