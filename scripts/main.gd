extends Control

func _ready() -> void:
	%SceneManager.load_scene(Scenes.get_scene("start_screen"), null, false)
	SignalBus.diamond_collected.connect(_on_diamond_connect)
	SignalBus.show_ui.connect(_on_show_ui)
	
func reset():
	pass
	
func _on_diamond_connect(total_diamonds):
	%DiamondsLabel.text = str(total_diamonds)

func _on_show_ui():
	%UI.visible = true
