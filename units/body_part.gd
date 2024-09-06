extends Area3D

@export var multiplier = 1

signal hit_signal(damage: int)

func hit(dam: int):
	hit_signal.emit(dam * multiplier)
