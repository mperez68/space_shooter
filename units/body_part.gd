extends Area3D

@export var multiplier = 1

signal hit(damage: int)

func process_hit(dam: int):
	hit.emit(dam * multiplier)
