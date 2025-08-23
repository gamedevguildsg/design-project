class_name Spike
extends Node2D

func _ready() -> void:
	%SpikeHitbox.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D):
	if body is Player:
		var player : Player = body
		player.kill("spike")
