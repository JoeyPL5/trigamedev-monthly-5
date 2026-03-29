extends Node

@export var button_click : AudioStreamPlayer2D
@export var button_hover : AudioStreamPlayer2D
@export var scratch_1 : AudioStreamPlayer2D
@export var scratch_2 : AudioStreamPlayer2D
@export var scratch_3 : AudioStreamPlayer2D
@export var horror : AudioStreamPlayer2D

var scratch_sounds : Array[AudioStreamPlayer2D]

func _ready() -> void:
	scratch_sounds = [scratch_1, scratch_2, scratch_3]

func play_random_scratch() -> void:
	var sound: AudioStreamPlayer2D = scratch_sounds.pick_random()
	play_sound_effect(sound, 0.15)

func play_sound_effect(sound_node : AudioStreamPlayer2D, pitch_variance : float = 0.0) -> void:
	if sound_node == null:
		return
	var dupe_sound : AudioStreamPlayer2D = sound_node.duplicate(false)
	if pitch_variance > 0.0:
		dupe_sound.pitch_scale = randf_range(1.0 - pitch_variance, 1.0 + pitch_variance)
	self.add_child(dupe_sound)
	dupe_sound.play()
	await dupe_sound.finished
	dupe_sound.queue_free()
