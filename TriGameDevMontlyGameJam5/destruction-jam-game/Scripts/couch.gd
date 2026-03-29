extends Node2D

@export var destruction_clouds: GPUParticles2D


func _ready() -> void:
	$Sprite2D.play("default")


func play_destroyed() -> void:
	Animations.clean_particle_emission(destruction_clouds)
	$Sprite2D.play("destroyed")
