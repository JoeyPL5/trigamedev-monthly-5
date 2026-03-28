extends Node2D

# The Level is where we can call the clicking animations + progress animations
func _input(event):
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		
		$CatPlayer.play_click_animation()
		$ProgressBarUI.add_progress(3)
	
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
