extends Control

func _ready() -> void:
	%SceneManager.load_scene(Scenes.get_scene("start_screen"), null, false)
