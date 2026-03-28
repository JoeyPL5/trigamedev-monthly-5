extends Control

@onready var bar: ProgressBar = $ProgressBar

@export var increment: float = 2.0
@export var fill_duration: float = 0.4


#func _input(event):
	#if event is InputEventMouseButton \
	#and event.pressed \
	#and event.button_index == MOUSE_BUTTON_LEFT:
		#
		#add_progress(increment)


func add_progress(amount: float) -> void:
	var target: float = clamp(
		bar.value + amount,
		bar.min_value,
		bar.max_value
	)

	Animations.tween_progress_bar(bar, bar.value, target, fill_duration)
