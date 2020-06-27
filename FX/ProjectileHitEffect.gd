extends Node2D


func _ready():
	$Particle.emitting = true
	$Animation.play("Hit")


func _on_ParticleTimeout_timeout():
	$Particle.emitting = false


func _on_EmitterTimeout_timeout():
	queue_free()
