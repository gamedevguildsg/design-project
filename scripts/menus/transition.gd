extends CanvasLayer

@export var delay := 1
@export var start_color := Color(0.5, 0, 1)
@export var end_color := Color(0, 0, 0)
@export_range(5,50,0.1) var start_size := 30.0
@export_range(5,50,0.1) var end_size := 10.0

@export var demo := false

@onready var background = $ColorRect

func _ready() -> void:
	SignalBus.play_transition.connect(self.start)
	# get the background ready for the first time we call start()
	background.color = end_color
	background.material.set_shader_parameter("progress", 0.0)
	background.material.set_shader_parameter("diamondPixelSize", end_size)

  
func start():
	# disable input while we're swapping the screen
	get_tree().get_root().set_disable_input(true)

	# start the wipe in that hides our swap
	await wipe(start_color, start_size, 1.0)

	# announce it's okay to change the screen now
	SignalBus.transition_covered.emit()

	# wait for signal before transitioning back in
	await SignalBus.play_transition_out
	await wipe(end_color, end_size, 0.0)

	# re-enable input now it's over
	get_tree().get_root().set_disable_input(false)

	# announce everything's done and back to normal
	SignalBus.transition_finished.emit()
  


func wipe(to_color : Color, to_size : float, to_fade : float, direction : int = -1, easing : Tween.EaseType = Tween.EASE_IN, transition : Tween.TransitionType = Tween.TRANS_CUBIC):
	if demo: print("transition demo: starting wipe %s" % [to_fade])

	# see the shader for what the direction param does
	background.material.set_shader_parameter("wipeDirection", randi_range(0,8) if direction == -1 else direction)

	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(background, "color", to_color, delay).set_trans(transition).set_ease(easing)
	tween.tween_property(background.material, "shader_parameter/progress", to_fade, delay).set_trans(transition).set_ease(easing)
	tween.tween_property(background.material, "shader_parameter/diamondPixelSize", to_size, delay).set_trans(transition).set_ease(easing)

	tween.play()
	await tween.finished

	if demo: print("transition demo: finished wipe %s" % [to_fade])
