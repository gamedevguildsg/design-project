class_name Exit
extends StaticBody2D

@export var go_to_scene : String

func _ready() -> void:
	%Area2D.body_entered.connect(_on_body_enter)
	
func _on_body_enter(body: Node2D):
	if body is Player:
		var player : Player = body
		player.is_frozen = true
		print("You win!")
		if go_to_scene:
			SignalBus.load_scene.emit(go_to_scene)
