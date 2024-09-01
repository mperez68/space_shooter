extends Menu
class_name CharacterSelectMenu


func _on_back_pressed() -> void:
	transition.emit(MENU.CORE)


func _on_next_pressed() -> void:
	transition.emit(MENU.MISSION_SELECT)
