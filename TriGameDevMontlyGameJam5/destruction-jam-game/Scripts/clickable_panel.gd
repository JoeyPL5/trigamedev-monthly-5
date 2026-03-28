extends Panel


@export var mouse_area : ParentMouseAreaRect

func _ready() -> void:
	mouse_area.update_shape.emit()

func _on_mouse_area_click() -> void:
	SoundFX.play_sound_effect(SoundFX.button_click)

func _on_mouse_entered() -> void:
	SoundFX.play_sound_effect(SoundFX.button_hover)
