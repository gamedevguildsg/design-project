extends Node

var gravity : float = 700

func set_level_data(options):
	if "gravity" in options:
		gravity = options.gravity
