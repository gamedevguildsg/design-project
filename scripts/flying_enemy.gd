@tool
class_name FlyingEnemy
extends Node2D

@export var speed := 30

var moving := false
var reverse_direction := false

func _ready() -> void:
	%Area2D.body_entered.connect(_on_body_entered)
	%AnimatedSprite2D.play("default")
	moving = true

func _on_body_entered(body : Node2D):
	if not body is Player:
		return
	var player : Player = body
	player.hit()

func _physics_process(delta: float) -> void:
	if not moving:
		return
	if not %PathFollow2D: # node not ready
		return
	if not reverse_direction:
		%PathFollow2D.progress += speed * delta
		if %PathFollow2D.progress_ratio >= 0.99:
			%PathFollow2D.progress_ratio = 0.99
			reverse_direction = true
	else:
		%PathFollow2D.progress -= speed * delta
		if %PathFollow2D.progress_ratio <= 0.01:
			%PathFollow2D.progress_ratio = 0.01
			reverse_direction = false
