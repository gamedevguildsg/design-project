extends Node2D

var activated := false

func _ready() -> void:
	%CheckpointHitbox.body_entered.connect(_on_hit_checkpoint)

func activate():
	var tween : Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(%CheckpointSprite, "position:y", 22, 1)
	SignalBus.set_checkpoint_position.emit(self.global_position)
	
func _on_hit_checkpoint(body : Node):
	if activated:
		return
	if not body is Player:
		return
	self.activate()
		
