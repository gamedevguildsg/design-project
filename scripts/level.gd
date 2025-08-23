class_name Level
extends Node2D

@export var gravity : float = 300
@export var level_bgm : AudioStream

var checkpoint_position : Vector2
var player : Player

func _ready() -> void:
	LevelData.set_level_data({
		"gravity" : gravity
	})
	if level_bgm:
		Audio.set_and_play_bgm(level_bgm)
	SignalBus.set_checkpoint_position.connect(_on_set_checkpoint_position)
	SignalBus.player_died.connect(_on_player_death)
	spawn_player(%InitialSpawnPoint.global_position)
	
func _on_set_checkpoint_position(position : Vector2):
	checkpoint_position = position + Vector2(0, -5)
	
func _on_player_death():
	var position = checkpoint_position if checkpoint_position else %InitialSpawnPoint.global_positiond
	spawn_player(position)
	
func spawn_player(position):
	if not player:
		var player_scene : Player = Scenes.get_scene("player")
		self.add_child(player_scene)
		self.player = player_scene

	player.global_position = position
	player.is_dead = false
	player.is_frozen = false
	player.blinking_animation()
	player.set_camera_boundaries(
		%Area2D.position.x,
		%Area2D.position.x + %LevelBoundary.shape.size.x,
		%Area2D.position.y,
		%Area2D.position.y + %LevelBoundary.shape.size.y
	)
	player.get_node("%Sprite").visible = true
