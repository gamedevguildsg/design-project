class_name Enemy
extends CharacterBody2D

@export_enum("Walk Back and Forth") var ai_mode
@export var walk_speed := 30
@export var turn_around_on_platform_edge := true
@export var damage_player_on_contact := true

var walk_direction := -1 # -1 for left, 1 for right
func _ready():
	%Area2D.body_entered.connect(_on_body_entered)
	velocity.x = walk_speed * walk_direction
	%Sprite2D.play("walk")
	
func turn():
	if walk_direction == -1:
		walk_direction = 1
	else:
		walk_direction = -1
	velocity.x = walk_speed * walk_direction
	%Sprite2D.scale.x = -walk_direction

func _physics_process(delta: float) -> void:
	if is_on_floor():
		if not %RayCast2D.is_colliding() or is_on_wall():
			turn()
		
	# gravity
	if LevelData.gravity > 0:
		velocity.y += LevelData.gravity * delta
	
	move_and_slide()


func _on_body_entered(body : Node2D):
	if body is Player:
		if damage_player_on_contact:
			var player : Player = body
			player.kill()
	if body is Enemy:
		var enemy : Enemy = body
		enemy.turn()
