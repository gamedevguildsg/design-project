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
var max_health
var current_health
var is_invulnerable := false

var player_options : PlayerOptions

## collectable data
var diamonds_collected := 0
var coins_collected := 0

## For dash animation
var duplicate_time_actual : float = 0
var duplicate_time_gap := 0.03
var duplicate_lifetime := 0.3
var dash_current_duration : float = 0

## health texture
var full_heart_texture = load("res://assets/tiles/tile_0044.png")
var half_heart_texture = load("res://assets/tiles/tile_0045.png")
var empty_heart_texture = load("res://assets/tiles/tile_0046.png")

func _ready() -> void:
	%Hurtbox.body_entered.connect(_on_enter_hurtbox)
	%Animations.animation = "none"
	%Animations.animation_finished.connect(_on_animation_finished)
	
func set_player_options(options):
	player_options = options
	jumps_left = player_options.no_jumps
	dashes_left = player_options.no_dashes
	max_jump_speed = player_options.max_walk_speed
	if player_options.max_health > 0:
		max_health = player_options.max_health
		current_health = max_health
		update_health_display()
		
func _on_enter_hurtbox(body: Node2D):
	pass

var max_jump_speed
func jump():
	if jumps_left <= 0:
		return
	jumps_left -= 1
	velocity.y = -player_options.jump_strength
	%AudioManager.play_sound("jump")
		
func fall_through():
	position.y += 1
	
func hit(damage = 1):
	if is_invulnerable:
		return
	if player_options.invuln_while_dashing and is_dashing:
		return
	if not current_health:
		kill()
		return
		
	current_health -= damage
	if current_health <= 0:
		kill()
		return
	%AudioManager.play_sound("hit")
	
	update_health_display()
	blinking_animation()
	
func kill(reason : String = "fall_below"):
	is_invulnerable = true
	is_dead = true
	%Sprite.visible = false
	current_health = 0
	update_health_display()
	
	match reason:
		"fall_below":
			%Animations.play("death_from_below")
		"spike":
			%Animations.play("spike_death")
	%AudioManager.play_sound("death")
	await %Animations.animation_finished 
	SignalBus.player_died.emit()
	
func blinking_animation():
	is_invulnerable = true
	for _i in 5:
		%Sprite.modulate.a = 0
		await get_tree().create_timer(0.08).timeout
		%Sprite.modulate.a = 1
		await get_tree().create_timer(0.08).timeout
	is_invulnerable = false

func update_health_display():
	%HeartContainer.get_children().map(func(n : Node): %HeartContainer.remove_child(n))
	if not current_health:
		return
	for _i in floor(current_health):
		var heart = TextureRect.new()
		heart.texture = full_heart_texture
		%HeartContainer.add_child(heart)
	for _i in floor(max_health - current_health):
		var empty_heart = TextureRect.new()
		empty_heart.texture = empty_heart_texture
		%HeartContainer.add_child(empty_heart)
	

func _on_animation_finished():
	%Animations.animation = "none"

var previous_frame_vertical_speed : float = 0
var dash_cooldown : float = 0
func _physics_process(delta: float) -> void:
	if is_dead or is_frozen:
		return
	if is_dashing:
		handle_dash_state(delta)
		return # return as we don't want it to be affected by terminal velocity
	if dash_in_cooldown:
		dash_cooldown += delta
		if dash_cooldown > player_options.dash_cooldown:
			dash_cooldown = 0
			dash_in_cooldown = false
	
	if is_on_floor():
		jumps_left = player_options.no_jumps
		dashes_left = player_options.no_dashes
	else:
		velocity.y += LevelData.gravity * delta
		if velocity.y > player_options.terminal_velocity:
			velocity.y = player_options.terminal_velocity
	var is_sprinting = player_options.can_run and Input.is_action_pressed("sprint")
	var sprinting_factor = player_options.run_speed_multiplier if is_sprinting else 1
	var input_direction = Input.get_axis("left", "right")
	var vertical_input_direction = Input.get_axis("up", "down")
	if remove_player_control:
		sprinting_factor = 1
		input_direction = 0
		vertical_input_direction = 0
		
	var max_speed = player_options.max_walk_speed * sprinting_factor
	var additional_friction = player_options.friction * sign(-velocity.x) if player_options.friction > 0 and \
		  (not sign(velocity.x) == sign(input_direction)) else 0
	var vertical_additional_friction = player_options.friction * sign(-velocity.y) if player_options.friction > 0 and \
		  (not sign(velocity.y) == sign(vertical_input_direction)) else 0
	
	if is_on_floor():
		if input_direction:
			if player_options.movement_acceleration > 0:
				velocity.x += (input_direction * player_options.movement_acceleration * sprinting_factor + additional_friction) * delta
				max_speed = player_options.max_walk_speed * sprinting_factor
				if abs(velocity.x) > max_speed:
					velocity.x = input_direction * max_speed

			else:
				velocity.x = input_direction * player_options.max_walk_speed * sprinting_factor
			%Sprite.play("walk")
			%Sprite.flip_h = input_direction > 0			
		else:
			# slow down due to friction
			if additional_friction:
				velocity.x += additional_friction * delta
				if sign(velocity.x) == sign(additional_friction):
					velocity.x = 0
			%Sprite.play("idle")
		if player_options.fall_damage_enabled:
			if previous_frame_vertical_speed - velocity.y > player_options.fall_damage_threshold:
				hit()
		
		
	## Handle jumps
	if Input.is_action_just_pressed("jump") and LevelData.gravity > 0:
		if vertical_input_direction > 0: # holding down to fall through
			fall_through()
		else:
			if is_on_floor():
				max_jump_speed = max_speed
			jump()
	
	## Handle dashing
	if player_options.can_dash and Input.is_action_just_pressed("dash"):
		start_dash(input_direction, vertical_input_direction)
	
	else: #mid-air
		if not player_options.can_steer_midair:
			move_and_slide()
			return
		if LevelData.gravity <= 0: # free steering with no gravity
			velocity.x += additional_friction * delta
			velocity.y += vertical_additional_friction * delta
			if sign(velocity.x) == sign(additional_friction):
				velocity.x = 0
			if sign(velocity.y) == sign(vertical_additional_friction):
				velocity.y = 0
		if player_options.air_acceleration > 0:
			velocity.x += input_direction * player_options.air_acceleration * sprinting_factor * delta
			if velocity.length() > player_options.terminal_velocity:
				velocity = velocity.normalized() * player_options.terminal_velocity

			if LevelData.gravity <= 0:
				velocity.y += vertical_input_direction * player_options.air_acceleration * sprinting_factor * delta
				if abs(velocity.y) > player_options.terminal_velocity:
					velocity.y = sign(velocity.y) * player_options.terminal_velocity
		if player_options.can_fast_fall and Input.is_action_pressed("down"):
			velocity.y += player_options.fast_fall_additional_speed * delta
		else:
			velocity.x = input_direction * player_options.max_walk_speed * sprinting_factor
	previous_frame_vertical_speed = velocity.y
	move_and_slide()

func start_dash(input_direction, vertical_input_direction):
	if dash_in_cooldown:
		if not is_on_floor() and not player_options.dash_cooldown_applies_while_in_air:
			pass
		else:
			print("[Player.handle_dash] Dash in cooldown!")
			return
	if dashes_left <= 0:
		print("[Player.handle_dash] No dashes left!")
		return
	if not player_options.can_air_dash and not is_on_floor():
		print("[Player.handle_dash] Cannot air dash!")
		return
		
	is_dashing = true
	dashes_left -= 1
	dash_in_cooldown = true
	velocity = Vector2(input_direction, vertical_input_direction).normalized() \
	  * player_options.dash_speed
	
	%AudioManager.play_sound("dash")

func spawn_reset():
	is_dead = false
	is_frozen = false
	blinking_animation()
	get_node("%Sprite").visible = true
	current_health = max_health
	update_health_display()

func handle_dash_state(delta):
	dash_current_duration += delta
	if dash_current_duration > player_options.dash_duration:
		is_dashing = false
		dash_current_duration = 0
		# remove momentum from the dash
		if velocity.length() > player_options.max_walk_speed:
			velocity = velocity.normalized() * player_options.max_walk_speed
		
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

func set_camera_zoom(zoom_level):
	%Camera2D.zoom = Vector2(zoom_level, zoom_level)
