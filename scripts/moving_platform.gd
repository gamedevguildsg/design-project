@tool
class_name MovingPlatform
extends Node2D

## How many tiles long is the platform
@export var size : int = 1 :
	set(value):
		size = value
		if not Engine.is_editor_hint():
			await ready # wait for the tree to be ready before changing controls
		%HBoxContainer.get_children().map(func(n : Node): %HBoxContainer.remove_child(n))
		for i in value:
			var texture_rect = TextureRect.new()
			texture_rect.texture = platform_texture
			%HBoxContainer.add_child(texture_rect)
			
		#adjust hitbox to fit the whole platform.
		await get_tree().process_frame
		var _size = %HBoxContainer.get_rect().size.x
		%CollisionShape2D.shape.size.x = _size
		%CollisionShape2D.position.x = _size / 2
		size = value
		
## How fast the platform is moving
@export var speed := 20
## From 0 to 1, at what point in the path does the platform start moving from
@export var start_position : float :
	set(value):
		if not Engine.is_editor_hint():
			await ready # wait for the tree to be ready before changing controls
		%PathFollow2D.progress_ratio = value
		start_position = value

	
var moving := false
var platform_texture = load("res://assets/Tiles/tile_0147.png")


func _ready() -> void:	
	moving = true
	
var reverse_direction := false
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
