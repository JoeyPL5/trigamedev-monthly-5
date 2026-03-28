extends CanvasLayer


func change_scene(scene_file : String) -> void:
	self.scene_to_load = scene_file
	self.visible = true
	ResourceLoader.load_threaded_request(scene_file)
