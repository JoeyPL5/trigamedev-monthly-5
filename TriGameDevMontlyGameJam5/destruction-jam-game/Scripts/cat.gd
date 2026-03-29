extends Area2D

@onready var cat_animation_player : AnimationPlayer = get_node("CatV2/AnimationPlayer")

	
#func _unhandled_input(event):
	#if event is InputEventMouseButton \
	#and event.pressed \
	#and event.button_index == MOUSE_BUTTON_LEFT:
		#
		#clicked.emit()
		#play_click_animation()

func play_click_animation():
	cat_animation_player.play("catScratch")
	pass

func stop_click_animation():
	pass
