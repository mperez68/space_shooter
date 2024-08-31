extends Node2D

func _ready() -> void:
	print("main menu")
	get_tree().change_scene_to_file("res://levels/debugmap.tscn")
