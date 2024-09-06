extends CanvasLayer

func getBoostBar():
	return $Fx/BoostBar


func _on_reticle_feedback() -> void:
	$Fx/Reticle.hit()
