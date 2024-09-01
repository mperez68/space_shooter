extends Menu
class_name MainMenu

func _on_play_pressed() -> void:
	transition.emit(MENU.CHARACTER_SELECT)

func _on_settings_pressed() -> void:
	transition.emit(MENU.SETTINGS)

func _on_exit_pressed() -> void:
	get_tree().quit()
