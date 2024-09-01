extends Node3D

@export var next_level: PackedScene = null

@onready var menu = $MenuController

func pause_menu(open = true):
	if open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		menu.start()
		get_tree().paused = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		menu.stop()
		get_tree().paused = false
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pause_menu()

func end_level(success: bool):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# TODO SPC-25: display debrief, make buttons for next level or return to menu
	print(next_level)
	if next_level == null:
		get_tree().change_scene_to_file("res://main_menu.tscn")
	else:
		get_tree().change_scene_to_packed(next_level)
