extends Menu
class_name InGameMenu

signal close_menu

var exit_warning = false
var exit_warning_text = "ARE YOU SURE?"

@onready var exit_text = $Exit.text

func _on_resume_pressed() -> void:
	_reset_exit_button()
	close_menu.emit()


func _on_settings_pressed() -> void:
	_reset_exit_button()
	transition.emit(MENU.SETTINGS)


func _on_exit_pressed() -> void:
	if (exit_warning):
		exit_warning = false
		get_tree().paused = false
		get_tree().change_scene_to_file("res://menu/main_menu.tscn")
	else:
		exit_warning = true
		$Exit.text = exit_warning_text

func _reset_exit_button():
	exit_warning = false
	$Exit.text = exit_text
	
