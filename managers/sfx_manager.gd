extends Node

enum AUDIO{ JUMP, BOOST, LAND, SHOOT, WALKING }

@onready var jump = $Jump
@onready var land = $Land
@onready var walk = $Walk
@onready var boost = $Boost

func play(a: AUDIO, stop = false):
	var sel: AudioStreamPlayer3D
	match a:
		AUDIO.JUMP:
			sel = $Jump
		AUDIO.BOOST:
			sel = $Boost
		AUDIO.LAND:
			sel = $Land
		AUDIO.WALKING:
			sel = $Walk
	if (stop):
		sel.stop()
	else:
		sel.play()
