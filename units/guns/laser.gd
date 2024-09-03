extends Node3D

@export var SPEED = 40.0
@export var DAMAGE = 1

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D
@onready var timer = $HitTimer

func _process(delta):
	if !timer.is_stopped():
		return
	
	if ray.is_colliding():
		mesh.visible = false
		particles.emitting = true
		print("hit ", ray.get_collider())
		if ray.get_collider().is_in_group("unit") and !ray.get_collider().is_in_group("friendly"):
			ray.get_collider().process_hit(DAMAGE)
		timer.start()
	else:
		position += transform.basis * Vector3(0, 0, -SPEED) * delta


func _on_timer_timeout() -> void:
	queue_free()
