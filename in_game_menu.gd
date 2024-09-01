extends Menu
class_name InGameMenu

signal close_menu

var exit_warning = false

func _on_resume_pressed() -> void:
	exit_warning = false
	close_menu.emit()


func _on_settings_pressed() -> void:
	exit_warning = false
	transition.emit(MENU.SETTINGS)


func _on_exit_pressed() -> void:
	if (exit_warning):
		exit_warning = false
		get_tree().paused = false
		get_tree().change_scene_to_file("res://main_menu.tscn")
	else:
		exit_warning = true
		$Exit.text = "ARE YOU SURE?"
