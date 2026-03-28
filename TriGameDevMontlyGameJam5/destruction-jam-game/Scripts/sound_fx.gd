extends Node

@export var button_click : AudioStreamPlayer2D
@export var button_hover : AudioStreamPlayer2D
@export var placeholder : AudioStreamPlayer2D


func play_sound_effect(sound_node : AudioStreamPlayer2D) -> void:
	if sound_node == null:
		return
	var dupe_sound : AudioStreamPlayer2D = sound_node.duplicate(false)
	self.add_child(dupe_sound)
	dupe_sound.play()
	await dupe_sound.finished
	dupe_sound.queue_free()
