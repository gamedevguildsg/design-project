class_name PlayerAudioOptions
extends AudioStreamPlayer

@export var sounds : Dictionary[String, AudioStream]

func play_sound(name : String):
	if name not in sounds:
		print("Sound %s not set!" % name)
		return
	
	if !playing : self.play()
	
	var poly_stream_playback = self.get_stream_playback()
	poly_stream_playback.play_stream(sounds[name])
	
