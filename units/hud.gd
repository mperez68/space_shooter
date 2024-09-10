extends CanvasLayer

func getBoostBar():
	return $Fx/BoostBar


func _on_reticle_feedback() -> void:
	$Fx/Reticle.hit()

func set_damage(health: int, shield: int):
	$Fx/HP.value = health
	$Fx/Shield.value = shield
