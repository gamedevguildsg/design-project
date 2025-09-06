extends Panel

var currentScene
func _ready() -> void:
	SignalBus.load_scene.connect(load_scene)
	
func remove_loaded_scenes() -> void:
	for n : Node in %LevelContainer.get_children():
		n.queue_free()
		
func load_scene(s, args = null, transition = true) -> void:
	if transition:
		SignalBus.play_transition.emit()
		await SignalBus.transition_covered
		
	self.remove_loaded_scenes()
	
	if s is String:
		s = Scenes.get_scene(s)
	%LevelContainer.add_child(s)
	
	if s.has_method("initialize"):
		if args:
			s.initialize(args)
		else:
			s.initialize()
			
	if transition:
		await self.get_tree().process_frame
		SignalBus.play_transition_out.emit()
	
	currentScene = s

func reload_current_scene(args = null):
	load_scene(currentScene, args)
