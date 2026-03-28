extends CanvasLayer

@export var bg : Panel
@export var transition_duration : float = Animations.DEFAULT_ENTRANCE_ANIMATION_DUR


func _ready() -> void:
	bg.position = Vector2(0, -bg.size.y)
	change_scene("res://Scenes/Menus/MainMenuUI.tscn")


func change_scene(scene_file : String) -> void:
	ResourceLoader.load_threaded_request(scene_file)
	var offscreen_position : Vector2 = Vector2(0, -bg.size.y)
	Animations.tween_position(bg, offscreen_position, Vector2.ZERO - offscreen_position, transition_duration)
	await thread_load_scene(scene_file)
	get_tree().change_scene_to_file(scene_file)
	Animations.tween_position(bg, Vector2.ZERO, (offscreen_position * Vector2(1, -1)) - Vector2.ZERO, transition_duration)
	
	
func thread_load_scene(scene_file : String) -> void:
	var thread_status : int = ResourceLoader.load_threaded_get_status(scene_file)
	while thread_status != 3:
		match thread_status:
			0, 2:
				return
			_:
				pass
		await get_tree().process_frame
		thread_status = ResourceLoader.load_threaded_get_status(scene_file)
	
