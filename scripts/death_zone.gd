class_name DeathZone
extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D):
	if body is Player:
		var player : Player = body
		player.kill()
		
