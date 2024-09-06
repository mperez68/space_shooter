extends MeshInstance3D

@onready var hit_particles = $GPUParticles3D

func init(start, end):
	var draw_mesh = ImmediateMesh.new()
	mesh = draw_mesh
	draw_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material_override)
	draw_mesh.surface_add_vertex(start)
	draw_mesh.surface_add_vertex(end)
	draw_mesh.surface_end()

func hit(start: Vector3, end: Vector3):
	hit_particles.position = end
	hit_particles.look_at(start)
	hit_particles.emitting = true

func _on_timer_timeout() -> void:
	queue_free()
