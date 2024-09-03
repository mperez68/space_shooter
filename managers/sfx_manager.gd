extends Node

enum AUDIO{ JUMP, BOOST, LAND, SHOOT, WALKING }

@onready var jump = $Jump
@onready var land = $Land
@onready var walk = $Walk
@onready var boost = $Boost
@onready var shoot = $Shoot

func play(a: AUDIO, stop = false):
	var sel: AudioStreamPlayer3D
	match a:
		AUDIO.JUMP:
			sel = $Jump
		AUDIO.BOOST:
			sel = $Boost
		AUDIO.LAND:
			sel = $Land
		AUDIO.SHOOT:
			sel = $Shoot
		AUDIO.WALKING:
			sel = $Walk
	if (stop):
		sel.stop()
	else:
		if !sel.playing or (sel.get_playback_position() > 0.1):	# prevent rapid re-trigger
			sel.play()
		
