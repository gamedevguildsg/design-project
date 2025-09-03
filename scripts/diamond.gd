class_name Diamond
extends Node2D

@export var refresh_dash_on_collect := true
@export var collect_sfx : AudioStream

func _ready():
	%Area2D.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body : Node):
	if body is Player:
		var player : Player = body
		player.diamonds_collected += 1
		if refresh_dash_on_collect:
			player.dash_in_cooldown = false
			player.dashes_left += 1
		SignalBus.diamond_collected.emit(player.diamonds_collected)
		if collect_sfx:
			%AudioStreamPlayer.stream = collect_sfx
			%AudioStreamPlayer.play()
		var tween := create_tween()
		tween.parallel()
		tween.tween_property(self, "position:y", -3, 0.15).as_relative()
		tween.tween_property(self, "modulate:a", 0, 0.15)
		await tween.finished
		queue_free()
	
