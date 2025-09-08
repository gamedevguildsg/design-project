class_name PlayerOptions
extends Node

## Walk speed of the player.
@export var max_walk_speed : float = 100

## Hold a button to move at a faster speed. By default, this is bound to [b]SHIFT[/b].
@export var can_run := true
## When running, your movement speed is multiplied by this value.
@export var run_speed_multiplier : float = 1.5
## Can move left and right mid-jump
@export var can_steer_midair := true
## Can dash. By default, this is bound to CTRL.
@export var can_dash := true
## How many dashes do you have until you land on the ground.
@export var no_dashes := 1
## How fast the character moves during a dash
@export var dash_speed : float = 350
## How long the player will be dashing for, in seconds.
@export var dash_duration := 0.08
## Can you dash in the air?
@export var can_air_dash := true
## If enabled, the player cannot get hit while dashing.
@export var invuln_while_dashing := true
## After dashing, the player cannot dash for this amount of time.
@export var dash_cooldown := 0.5
## Does the above dash cooldown apply while the player is airborne? You may want to disable this for better feeling airdashes.
@export var dash_cooldown_applies_while_in_air := false
## Acceleration the player has until they reach top speed. If set to 0, the player will reach max speed immediately
@export var movement_acceleration : float = 400 
## Acceleration the player has when attempting to steer mid air. If set to 0, the player will reach max speed immediately. On applies when "Can Steer Midair" is enabled.
@export var air_acceleration : float = 200
## When there is no player input and the player character is moving, how fast the player will slow down.
@export var friction : float = 200
## How much health the player has. If set to 0, there is no health mechanic, and the player dies on one hit.
@export var max_health := 0 
## How many jumps does the player have. Resets when the player lands.
@export var no_jumps := 1
## How high the player jumps
@export var jump_strength : float = 200
## 
@export var fall_damage_enabled := false

## Holding down mid-air moves you down faster
@export var can_fast_fall := true
## How much faster does the player fall when holding down.
@export var fast_fall_additional_speed : float = 300

## Minimum speed at which the player will take fall damage.
@export var fall_damage_threshold : float = 500.0 

## Max speed while in the air.
@export var terminal_velocity : float = 700.0
