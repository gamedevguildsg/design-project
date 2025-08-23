class_name Exit
extends StaticBody2D


func _ready() -> void:
	%Area2D.body_entered.connect(_on_body_enter)
	
func _on_body_enter(body: Node2D):
	if body is Player:
		print("You win!")
