class_name Level
extends Node2D

@export var gravity : float = 300
@export var level_bgm : AudioStream
@export var min_camera_zoom := 1.5
@export var max_camera_zoom := 2.0

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
	SignalBus.show_ui.emit()
	spawn_player(%InitialSpawnPoint.global_position)
	
func _on_set_checkpoint_position(position : Vector2):
	checkpoint_position = position + Vector2(0, -5)
	
func _on_player_death():
	var position = checkpoint_position if checkpoint_position else %InitialSpawnPoint.global_position
	spawn_player(position)
	
func spawn_player(position):
	if not player:
		var player_scene : Player = Scenes.get_scene("player")
		self.add_child(player_scene)
		self.player = player_scene
		player.set_player_options(%PlayerOptions)

	player.global_position = position
	var viewport_size = get_viewport_rect().size
	var camera_left_x = %LevelBoundary.position.x - %LevelBoundary.shape.size.x / 2
	var camera_right_x = camera_left_x + %LevelBoundary.shape.size.x
	var camera_top_x = %LevelBoundary.position.y - %LevelBoundary.shape.size.y / 2
	var camera_bottom_x = camera_top_x + %LevelBoundary.shape.size.y
	var camera_scale_x = viewport_size.x / (camera_right_x - camera_left_x)
	var camera_scale_y = viewport_size.y / (camera_bottom_x - camera_top_x)
	var camera_scale = clamp(min(camera_scale_x, camera_scale_y), min_camera_zoom, max_camera_zoom)
	player.set_camera_zoom(camera_scale)
	player.set_camera_boundaries(
		camera_left_x,
		camera_right_x,
		camera_top_x,
		camera_bottom_x
	)
	player.spawn_reset()
	
