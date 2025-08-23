extends Control

func _ready() -> void:
	%BackToStart.pressed.connect(_on_back_to_start)
	
func _on_back_to_start():
	SignalBus.load_scene.emit(Scenes.get_scene("start_screen"))
