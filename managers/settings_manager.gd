extends Node

enum CHANNELS { MASTER, MUSIC, SFX }

const WINDOW_SIZE = Vector2i(1440, 900)

@onready var FULL_SIZE = DisplayServer.screen_get_size()


func full_screen():
	if (DisplayServer.window_get_mode()) == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
		DisplayServer.window_set_size(WINDOW_SIZE)
	else:
		DisplayServer.window_set_size(FULL_SIZE)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func borderless():
	get_tree().root.borderless = !get_tree().root.borderless

func get_audio_level(channel: CHANNELS) -> float:
	return db_to_linear(AudioServer.get_bus_volume_db(channel))

func set_audio_level(value: float, channel: CHANNELS):
	AudioServer.set_bus_volume_db(
		channel,
		linear_to_db(value)
	)
