extends Node3D

var SPEED: float = 100.0
var DAMAGE: int = 1
var RANGE: float = 100.0
var IS_PLAYER: bool = false
var start_pos: Vector3
var target: Vector3

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D
@onready var timer = $HitTimer

func set_params(target_in: Vector3, damage: int = DAMAGE, speed: float = SPEED, range_in: float = RANGE, is_player: bool = false):
	target = target_in
	DAMAGE = damage
	SPEED = speed
	IS_PLAYER = is_player
	RANGE = range_in
	start_pos = global_position

func _physics_process(delta):
	if !timer.is_stopped():
		return
	
	if ray.is_colliding():
		if IS_PLAYER == ray.get_collider().is_in_group("player"):
			move(delta)
			return
		print("hit ", ray.get_collider())
		if ray.get_collider().is_in_group("unit"):
			ray.get_collider().hit(DAMAGE)
	
	if ray.is_colliding() or position.distance_to(start_pos) > RANGE:
		position = ray.get_collision_point()
		mesh.visible = false
		particles.emitting = true
		timer.start()
	else:
		move(delta)

func move(delta):
	look_at(target)
	
	ray.target_position = Vector3(0, 0, - 1 - (SPEED * delta))
	var distance = transform.basis * Vector3(0, 0, -SPEED) * delta
	ray.position = Vector3(0, 0, 0.5) + Vector3(0, 0, SPEED) * delta
	position += distance

func _on_timer_timeout() -> void:
	queue_free()
