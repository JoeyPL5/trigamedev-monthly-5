extends Panel


@export var mouse_area : ParentMouseAreaRect

func _ready() -> void:
	mouse_area.update_shape.emit()
	

func _on_mouse_area_click() -> void:
	pass # TODO: Switch to game scene
