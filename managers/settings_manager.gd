extends Node

enum CHANNELS { MASTER, MUSIC, SFX }
var CHANNEL_NAMES = [ "master", "music", "sfx" ]

const WINDOW_SIZE = Vector2i(1440, 900)
const SAVE_PATH = "user://settings.cfg"

var config = ConfigFile.new()
var settings = "settings"
var borderless_set = "borderless"
var full_screen_set = "full_screen"

@onready var FULL_SIZE = DisplayServer.screen_get_size()


func _ready():
	if config.load(SAVE_PATH) != OK:
		return
	
	# retrieve saved settings
	if config.has_section_key(settings, borderless_set):
		get_tree().root.borderless = config.get_value(settings, borderless_set)
	
	if config.has_section_key(settings, full_screen_set) and \
			DisplayServer.window_get_mode() != config.get_value(settings, full_screen_set):
		full_screen()
	
	for channel in range(CHANNELS.size()) :
		if config.has_section_key(settings, CHANNEL_NAMES[channel]):
			set_audio_level(config.get_value(settings, CHANNEL_NAMES[channel]), channel)

func full_screen():
	if (DisplayServer.window_get_mode()) == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(WINDOW_SIZE)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.window_set_size(FULL_SIZE)
	config.set_value(settings, full_screen_set, DisplayServer.window_get_mode())

func borderless():
	get_tree().root.borderless = !get_tree().root.borderless
	config.set_value(settings, borderless_set, get_tree().root.borderless)

func get_audio_level(channel: CHANNELS) -> float:
	return db_to_linear( AudioServer.get_bus_volume_db(channel) )

func set_audio_level(value: float, channel: CHANNELS):
	AudioServer.set_bus_volume_db( channel, linear_to_db(value) )
	config.set_value(settings, CHANNEL_NAMES[channel], value)

func save_settings():
	config.save(SAVE_PATH)
