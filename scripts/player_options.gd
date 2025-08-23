class_name PlayerOptions
extends Node

@export var max_walk_speed : float = 150
@export var can_run := true
@export var run_speed_multiplier : float = 2.0
@export var can_steer_midair := true
@export var movement_acceleration : float = 400 # how fast the player accelerates when you press the input
@export var air_acceleration : float = 200 # mid-air steering speed. Set to 0 for instant speed.
@export var friction : float = 200 # how much the player slows down when input is let go. Set to 0 to disable.
@export var health := 0 # 0 means no health mechanic
@export var no_jumps := 1
@export var jump_strength : float = 200
@export var fall_damage_enabled := false

## Holding down mid-air moves you down faster
@export var can_fast_fall := true
@export var fast_fall_additional_speed : float = 300

## minimum speed to take fall damage
@export var fall_damage_threshold : float = 500.0 

## Max speed when falling
@export var terminal_velocity : float = 700.0
