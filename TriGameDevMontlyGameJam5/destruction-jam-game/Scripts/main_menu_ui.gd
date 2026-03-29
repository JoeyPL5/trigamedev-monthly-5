extends Control
class_name MainMenuUI

@export var introScene : PackedScene
@export var play_button : ClickablePanel

@onready var play_mouse_area : ParentMouseAreaRect = play_button.mouse_area

func _ready() -> void:
	connect_signals()
	
func connect_signals() -> void:
	play_mouse_area.connect("on_click", _on_play_click)


func _on_play_click() -> void:
	SceneLoader.change_scene(introScene.resource_path)
	
	
	
	
	
