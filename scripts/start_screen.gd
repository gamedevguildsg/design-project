extends Control

@export var starting_level = "level_2"
func _ready() -> void:
	%Start.pressed.connect(_on_start_game)
	
	
func _on_start_game():
	SignalBus.load_scene.emit(Scenes.get_scene(starting_level))
