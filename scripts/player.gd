class_name Player
extends CharacterBody2D

enum STATE {
	WALK,
	RUN,
}
var _state 
var jumps_left
var dashes_left
var dash_in_cooldown := false
var is_dead := false
var is_dashing := false
var is_frozen := false
var remove_player_control := false

## collectable data
var diamonds_collected := 0
var coins_collected := 0

## For dash animation
var duplicate_time_actual : float = 0
var duplicate_time_gap := 0.03
var duplicate_lifetime := 0.3
var dash_current_duration : float = 0

func _ready() -> void:
	jumps_left = %PlayerOptions.no_jumps
	dashes_left = %PlayerOptions.no_dashes
	max_jump_speed = %PlayerOptions.max_walk_speed
	%Hurtbox.body_entered.connect(_on_enter_hurtbox)
	%Animations.animation = "none"
	%Animations.animation_finished.connect(_on_animation_finished)
	
func _on_enter_hurtbox(body: Node2D):
	pass

var max_jump_speed
func jump():
	if jumps_left <= 0:
		return
	jumps_left -= 1
	velocity.y = -%PlayerOptions.jump_strength
	%AudioManager.play_sound("jump")
		
func fall_through():
	position.y += 1
	
func kill(reason : String = "fall_below"):
	is_dead = true
	%Sprite.visible = false
	match reason:
		"fall_below":
			%Animations.play("death_from_below")
		"spike":
			%Animations.play("spike_death")
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
	%Animations.animation = "none"

var dash_cooldown : float = 0
func _physics_process(delta: float) -> void:
	if is_dead or is_frozen:
		return
	if is_dashing:
		handle_dash_state(delta)
		return # return as we don't want it to be affected by terminal velocity
	if dash_in_cooldown:
		dash_cooldown += delta
		if dash_cooldown > %PlayerOptions.dash_cooldown:
			dash_cooldown = 0
			dash_in_cooldown = false
	
	if is_on_floor():
		jumps_left = %PlayerOptions.no_jumps
		dashes_left = %PlayerOptions.no_dashes
	else:
		velocity.y += LevelData.gravity * delta
		if velocity.y > %PlayerOptions.terminal_velocity:
			velocity.y = %PlayerOptions.terminal_velocity
			
	var is_sprinting = Input.is_action_pressed("sprint")
	var sprinting_factor = %PlayerOptions.run_speed_multiplier if is_sprinting else 1
	var input_direction = Input.get_axis("left", "right")
	var vertical_input_direction = Input.get_axis("up", "down")
	if remove_player_control:
		sprinting_factor = 1
		input_direction = 0
		vertical_input_direction = 0
		
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
		if vertical_input_direction > 0: # holding down to fall through
			fall_through()
		else:
			if is_on_floor():
				max_jump_speed = max_speed
			jump()
	
	## Handle dashing
	if %PlayerOptions.can_dash and Input.is_action_just_pressed("dash"):
		start_dash(input_direction, vertical_input_direction)
	
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
			if velocity.length() > %PlayerOptions.jump_strength:
				velocity = velocity.normalized() * %PlayerOptions.jump_strength

			if LevelData.gravity <= 0:
				velocity.y += vertical_input_direction * %PlayerOptions.air_acceleration * sprinting_factor * delta
				if abs(velocity.y) > max_jump_speed:
					velocity.y = sign(velocity.y) * max_jump_speed
		if %PlayerOptions.can_fast_fall and Input.is_action_pressed("down"):
			velocity.y += %PlayerOptions.fast_fall_additional_speed * delta
		else:
			velocity.x = input_direction * %PlayerOptions.max_walk_speed * sprinting_factor
	
	move_and_slide()

func start_dash(input_direction, vertical_input_direction):
	if dash_in_cooldown:
		if not is_on_floor() and not %PlayerOptions.dash_cooldown_applies_while_in_air:
			pass
		else:
			print("[Player.handle_dash] Dash in cooldown!")
			return
	if dashes_left <= 0:
		print("[Player.handle_dash] No dashes left!")
		return
	if not %PlayerOptions.can_air_dash and not is_on_floor():
		print("[Player.handle_dash] Cannot air dash!")
		return
		
	is_dashing = true
	dashes_left -= 1
	dash_in_cooldown = true
	
	velocity = Vector2(input_direction, vertical_input_direction).normalized() \
	  * %PlayerOptions.dash_speed
	
	%AudioManager.play_sound("dash")
	
func handle_dash_state(delta):
	dash_current_duration += delta
	if dash_current_duration > %PlayerOptions.dash_duration:
		is_dashing = false
		dash_current_duration = 0

		
	duplicate_time_actual += delta
	if duplicate_time_actual >= duplicate_time_gap:
		duplicate_time_actual = 0
		duplicate_sprite()
	move_and_slide()

func duplicate_sprite():
	var duplicate = %Sprite.duplicate(true)
	duplicate.material = %Sprite.material.duplicate(true)
	duplicate.material.set_shader_parameter("opacity", 0.4)
	duplicate.material.set_shader_parameter("r", 0.0)
	duplicate.material.set_shader_parameter("g", 0.0)
	duplicate.material.set_shader_parameter("b", 0.8)
	duplicate.material.set_shader_parameter("mix_color", 0.7)
	duplicate.global_position = %Sprite.global_position
	get_parent().add_child(duplicate)
	await get_tree().create_timer(duplicate_lifetime).timeout
	duplicate.queue_free()

func set_camera_boundaries(left, right, top, bottom):
	%Camera2D.limit_left = left
	%Camera2D.limit_right = right
	%Camera2D.limit_top = top
	%Camera2D.limit_bottom = bottom
