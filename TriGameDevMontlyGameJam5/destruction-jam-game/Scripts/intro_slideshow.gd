extends CanvasLayer

signal slideshow_finished

@export var slides : Array[Texture2D]
@export var slide_duration : float = 2.0
@export var fade_duration : float = 0.5
@export var slide_sound : AudioStreamPlayer2D
@export var next_scene : String

@onready var slide_display : TextureRect = $SlideDisplay
@onready var bg : ColorRect = $BG


func _ready() -> void:
	bg.modulate.a = 1.0
	slide_display.modulate.a = 0.0
	await get_tree().create_timer(1.0).timeout
	play_slideshow()


func play_slideshow() -> void:
	slide_display.modulate.a = 1.0
	for idx in slides.size():
		slide_display.texture = slides[idx]
		SoundFX.play_sound_effect(slide_sound)
		await get_tree().create_timer(slide_duration).timeout

	slideshow_finished.emit()
	slide_display.modulate.a = 0.0

	if next_scene != "":
		SceneLoader.change_scene(next_scene)
