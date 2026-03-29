extends Panel
class_name ClickablePanel

@export var mouse_area : ParentMouseAreaRect

func _ready() -> void:
	mouse_area.update_shape.emit()
