extends Menu
class_name SettingsMenu


func _on_back_pressed() -> void:
	transition.emit(MENU.CORE)
