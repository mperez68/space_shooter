extends Node3D
class_name AbstractGun

enum TYPE { HITSCAN, MISSILE }
enum GUN { NONE, RIFLE, SHOTGUN }

signal reticle_feedback

@export var gun_name: GUN = GUN.NONE
@export var type: TYPE = TYPE.MISSILE
@export var damage = 1
@export var cooldown = 0.2
@export var speed = 100.0
@export var fire_range = 100.0
@export var spread: float = 1
@export var viewport_position = Vector3(0.514, -0.328, -0.593)
@export var player = false

var slug = load("res://units/guns/abstractmissile.tscn")
var instance
var trail = load("res://units/guns/missile_trail.tscn")
var world

@onready var anim = $AnimationPlayer
@onready var cd = $Cooldown
@onready var barrel = $BarrelRayCast
@onready var reticle = $VisionRayCast
@onready var range_end = $RangeEnd

func _ready():
	cd.wait_time = cooldown
	if player:
		position = viewport_position
		reticle.position = -viewport_position + Vector3(0, 0, -1.223)
	reticle.target_position *= fire_range
	range_end.position *= fire_range

func shoot() -> bool:
	if !cd.is_stopped():
		return false
	
	cd.start()
	anim.play("shoot")
	if (type == TYPE.HITSCAN):
		_hitscan()
	else:
		_missile()
	
	return true

func _missile():
	if world == null:
		print("No world to attach child for missile!")
		return
	instance = slug.instantiate()
	instance.position = barrel.global_position
	instance.transform.basis = barrel.global_transform.basis
	world.add_child(instance)
	var target = Vector3(0,0,0)
	if reticle.is_colliding():
		target = reticle.get_collision_point()
	else:
		target = range_end.global_position
	instance.set_params(target, damage, speed, fire_range, player)

func _hitscan():
	instance = trail.instantiate()
	if reticle.is_colliding():
		instance.init(barrel.global_position, reticle.get_collision_point())
		if reticle.get_collider().is_in_group("unit"):
			print("hit ", reticle.get_collider())
			reticle.get_collider().hit(damage)
			reticle_feedback.emit()
	else:
		instance.init(barrel.global_position, range_end.global_position)
		
	world.add_child(instance)
	
	if reticle.is_colliding():
		instance.hit(barrel.global_position, reticle.get_collision_point())
	

func _on_cooldown_timeout() -> void:
	anim.play("idle")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "draw_gun"):
		anim.play("idle")
