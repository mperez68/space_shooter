extends Panel
class_name Menu

const MENU = preload("res://menu_controller.gd").MENU
signal transition(new_menu: MENU)

func fade(is_fading_in = true):
	if is_fading_in:
		$Fade.play("fade_in")
		visible = true
	else:
		$Fade.play("fade_out")

func _on_fade_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		visible = false

func fast_transition(is_fading_in = true):
	$Fade.play("show")
	visible = is_fading_in
	pass
