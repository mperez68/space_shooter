extends Menu
class_name MissionSelectMenu


func _on_back_pressed() -> void:
	transition.emit(MENU.CHARACTER_SELECT)


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/debugmap.tscn")
