extends Area2D

signal clicked

	
#func _unhandled_input(event):
	#if event is InputEventMouseButton \
	#and event.pressed \
	#and event.button_index == MOUSE_BUTTON_LEFT:
		#
		#clicked.emit()
		#play_click_animation()

func play_click_animation():
	$AnimatedSprite2D.play("scratch", 2)

func stop_click_animation():
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.frame = 0
