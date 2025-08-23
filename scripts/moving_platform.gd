class_name MovingPlatform
extends Node2D

@export var x_offset := 100
@export var y_offset := 100
@export var duration : float = 10

func _ready() -> void:
	#adjust hitbox to fit the whole platform
	var size = %HBoxContainer.get_rect().size.x
	%CollisionShape2D.shape.size.x = size
	%CollisionShape2D.position.x = size / 2
	
	start_movement()

func start_movement():
	var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops()
	tween.set_parallel(false)
	tween.tween_property(%AnimatableBody2D, "position", Vector2(x_offset, y_offset), duration / 2)
	tween.tween_property(%AnimatableBody2D, "position", Vector2.ZERO, duration / 2)
