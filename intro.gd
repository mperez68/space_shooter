extends AudioStreamPlayer3D

func _on_finished() -> void:
	$"../loop".play()
