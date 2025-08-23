extends Node

@export var levels : Dictionary[String, PackedScene]

func get_scene(scene_name : String):
	return levels[scene_name].instantiate()
