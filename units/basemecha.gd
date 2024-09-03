extends CharacterBody3D
class_name BaseMecha

enum STATE{ GROUND, RISING, FALLING }

const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 6.0
const AIRBORNE_MULTIPLIER = 3.0
const INERTIA_MULTIPLIER = 8.0

@export var sensitivity = 0.005
@export var gravity = 9.8
@export var show_body = true

@onready var sfx = $SfxManager
@onready var body = $Root/Skeleton3D
@onready var body_parts = [$Root/Skeleton3D/Arms, $Root/Skeleton3D/Head,
							$Root/Skeleton3D/Legs, $Root/Skeleton3D/Torso]
@onready var tree = $AnimationTree

func _ready() -> void:
	# turn body invisible if needed
	if (!show_body):
		for part in body_parts:
			part.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY

func animate(dir: Vector2):
	if (is_on_floor()):
		tree.set("parameters/conditions/moving", dir != Vector2.ZERO)
		tree.set("parameters/conditions/idle", dir == Vector2.ZERO)
	tree.set("parameters/conditions/grounded", is_on_floor())
	tree.set("parameters/conditions/jumping", !is_on_floor())
	tree.set("parameters/BlendSpace2D/blend_position", dir)
