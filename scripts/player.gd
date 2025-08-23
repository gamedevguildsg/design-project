class_name Player
extends CharacterBody2D

enum STATE {
	WALK,
	RUN
}
var _state 
var jumps_left
var is_dead := false

func _ready() -> void:
	jumps_left = %PlayerOptions.no_jumps
	max_jump_speed = %PlayerOptions.max_walk_speed
	%Hurtbox.body_entered.connect(_on_enter_hurtbox)
	%Animations.play("none")
	%Animations.animation_finished.connect(_on_animation_finished)
	
func _on_enter_hurtbox(body: Node2D):
	pass

var max_jump_speed
func jump():
	if jumps_left <= 0:
		return
	jumps_left -= 1
	velocity.y = -%PlayerOptions.jump_strength
func fall_through():
	position.y += 1
	
func kill():
	is_dead = true
	%Animations.play("death_from_below")
	%AudioManager.play_sound("death")
	await %Animations.animation_finished 
	SignalBus.player_died.emit()
	
func blinking_animation():
	for _i in 5:
		%Sprite.visible = false
		await get_tree().create_timer(0.15)
		%Sprite.visible = true
		await get_tree().create_timer(0.15)

func _on_animation_finished():
	%Animations.play("none")
	
func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if is_on_floor():
		jumps_left = %PlayerOptions.no_jumps
	else:
		velocity.y += LevelData.gravity * delta
		if velocity.y > %PlayerOptions.terminal_velocity:
			velocity.y = %PlayerOptions.terminal_velocity
	var is_sprinting = Input.is_action_pressed("sprint")
	var sprinting_factor = %PlayerOptions.run_speed_multiplier if is_sprinting else 1
	var input_direction = Input.get_axis("left", "right")
	var vertical_input_direction = Input.get_axis("up", "down")
	var max_speed = %PlayerOptions.max_walk_speed * sprinting_factor
	var additional_friction = %PlayerOptions.friction * sign(-velocity.x) if %PlayerOptions.friction > 0 and \
		  (not sign(velocity.x) == sign(input_direction)) else 0
	var vertical_additional_friction = %PlayerOptions.friction * sign(-velocity.y) if %PlayerOptions.friction > 0 and \
		  (not sign(velocity.y) == sign(vertical_input_direction)) else 0
		
	if is_on_floor():		
		if input_direction:
			if %PlayerOptions.movement_acceleration > 0:
				velocity.x += (input_direction * %PlayerOptions.movement_acceleration * sprinting_factor + additional_friction) * delta
				max_speed = %PlayerOptions.max_walk_speed * sprinting_factor
				if abs(velocity.x) > max_speed:
					velocity.x = input_direction * max_speed

			else:
				velocity.x = input_direction * %PlayerOptions.max_walk_speed * sprinting_factor
			%Sprite.play("walk")
			%Sprite.flip_h = input_direction > 0			
		else:
			# slow down due to friction
			if additional_friction:
				velocity.x += additional_friction * delta
				if sign(velocity.x) == sign(additional_friction):
					velocity.x = 0
			%Sprite.play("idle")
	
	## Handle jumps
	if Input.is_action_just_pressed("jump") and LevelData.gravity > 0:
		if vertical_input_direction > 0:
			fall_through()
		else:
			if is_on_floor():
				max_jump_speed = max_speed
			jump()
			
	else: #mid-air
		if not %PlayerOptions.can_steer_midair:
			move_and_slide()
			return
		if LevelData.gravity <= 0: # free steering with no gravity
			velocity.x += additional_friction * delta
			velocity.y += vertical_additional_friction * delta
			if sign(velocity.x) == sign(additional_friction):
				velocity.x = 0
			if sign(velocity.y) == sign(vertical_additional_friction):
				velocity.y = 0
		if %PlayerOptions.air_acceleration > 0:
			velocity.x += input_direction * %PlayerOptions.air_acceleration * sprinting_factor * delta
			if abs(velocity.x) > max_jump_speed:
				velocity.x = sign(velocity.x) * max_jump_speed
			if LevelData.gravity <= 0:
				velocity.y += vertical_input_direction * %PlayerOptions.air_acceleration * sprinting_factor * delta
				if abs(velocity.y) > max_jump_speed:
					velocity.y = sign(velocity.y) * max_jump_speed
		if %PlayerOptions.can_fast_fall and Input.is_action_pressed("down"):
			velocity.y += %PlayerOptions.fast_fall_additional_speed * delta
		else:
			velocity.x = input_direction * %PlayerOptions.max_walk_speed * sprinting_factor
	
	move_and_slide()
