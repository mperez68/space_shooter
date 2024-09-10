extends Menu
class_name SettingsMenu

const SAVE_PATH = "user://level.save"

@onready var sliders = [ $AudioSliders/MasterAudio, $AudioSliders/MusicAudio, $AudioSliders/SFXAudio ]
@onready var settings_manager = $SettingsManager

func _ready():
	var i = 0
	for slider in sliders:
		slider.value = settings_manager.get_audio_level(i)
		i += 1

func _on_back_pressed() -> void:
	settings_manager.save_settings()
	transition.emit(MENU.CORE)

func _on_fullscreen_pressed() -> void:
	settings_manager.full_screen()

func _on_windowed_pressed() -> void:
	settings_manager.borderless()

func _on_audio_value_changed(value: float, channel: int) -> void:
	settings_manager.set_audio_level(value, channel)


func _on_sfx_audio_drag_ended(value_changed: bool) -> void:
	if (value_changed):
		$Shoot.play()
