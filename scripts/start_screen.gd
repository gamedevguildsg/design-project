extends Control

func _ready() -> void:
	%Start.pressed.connect(_on_start_game)
	
	
func _on_start_game():
	SignalBus.load_scene.emit(Scenes.get_scene("level_1"))
