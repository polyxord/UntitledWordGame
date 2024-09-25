## A singleton that manages sounds.
extends Node


## Plays a one-time sound effect from the given audio stream. If
## [param randomize_pitch] is true, the pitch (+ tempo) is randomized.
func play_sfx(stream: AudioStream, randomize_pitch: bool = false) -> void:
	var sfx_player := AudioStreamPlayer.new()
	sfx_player.stream = stream
	if randomize_pitch:
		sfx_player.pitch_scale = randf_range(0.5, 1.0)
	sfx_player.bus = "SFX"
	sfx_player.finished.connect(sfx_player.queue_free)
	add_child(sfx_player)
	sfx_player.play()
