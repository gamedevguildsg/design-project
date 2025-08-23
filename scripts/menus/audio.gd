extends Node

func set_and_play_bgm(audio : AudioStream):
	%BGM.stream = audio
	%BGM.play()

func pause_bgm():
	%BGM.stream_paused = true
func resume_bgm():
	%BGM.stream_paused = false
