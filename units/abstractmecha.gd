extends CharacterBody3D
class_name AbstractMecha

enum STATE{ GROUND, RISING, FALLING }

const AIRBORNE_MULTIPLIER = 3.0
const INERTIA_MULTIPLIER = 8.0

@export var MAX_HEALTH = 3
@export var MAX_SHIELD = 0
@export var WALK_SPEED = 5.0
@export var SPRINT_SPEED = 8.0
@export var JUMP_VELOCITY = 6.0
@export var sensitivity = 0.005
@export var gravity = 9.8
@export var show_body = true

var health = MAX_HEALTH
var shield = MAX_SHIELD
var speed = WALK_SPEED
var state = STATE.GROUND

@onready var sfx = $SfxManager
@onready var body = $Root/Skeleton3D
@onready var body_parts = [$Root/Skeleton3D/Arms, $Root/Skeleton3D/Head,
							$Root/Skeleton3D/Legs, $Root/Skeleton3D/Torso]
@onready var bones = [$Root/Skeleton3D/TorsoBone/Torso, $Root/Skeleton3D/HeadBone/Head,
	$Root/Skeleton3D/ArmUpperLeft/LeftArm, $Root/Skeleton3D/ArmUpperRight/RightArm,
	$Root/Skeleton3D/ArmLowerLeft/LeftArmLow, $Root/Skeleton3D/ArmLowerRight/RightArmLow,
	$Root/Skeleton3D/LegUpperLeft/LeftLeg, $Root/Skeleton3D/LegUpperRight/RightLeg,
	$Root/Skeleton3D/LegLowerLeft/LeftLegLow, $Root/Skeleton3D/LegLowerRight/RightLegLow]
@onready var tree = $AnimationTree
@onready var delay = $RechargeDelay
@onready var tick = $RechargeTick
@onready var shield_anim = $Shield/AnimationPlayer
@onready var skeleton = $Root/Skeleton3D

func _ready() -> void:
	# turn body invisible if needed
	if (!show_body):
		for part in body_parts:
			part.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	
	var parent = get_parent().get_parent()
	if parent:
		gravity = parent.gravity

func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		if velocity.y < 0:
			change_state(STATE.FALLING)
	
	if is_on_floor():
		change_state(STATE.GROUND)

func animate(dir: Vector2):
	if (is_on_floor()):
		tree.set("parameters/conditions/moving", dir != Vector2.ZERO)
		tree.set("parameters/conditions/idle", dir == Vector2.ZERO)
	tree.set("parameters/conditions/grounded", is_on_floor())
	tree.set("parameters/conditions/jumping", !is_on_floor())
	tree.set("parameters/BlendSpace2D/blend_position", dir)

func change_state(new_state: STATE):
	if state == new_state:
		# no change
		return
	
	_change_state(new_state)
	
	# update
	state = new_state

func _change_state(new_state: STATE):
	if state == STATE.GROUND and new_state == STATE.RISING:
		sfx.play(sfx.AUDIO.JUMP)
	
	if state == STATE.FALLING and new_state == STATE.GROUND:
		sfx.play(sfx.AUDIO.LAND)


func hit(damage: int) -> void:
	# If recharging, reset timer. Otherwise, start recharge timer.
	delay.start(delay.wait_time)
	tick.stop()
	# Damange shield first, overflow to health
	if shield > 0:
		shield_anim.play("effect")
		shield -= damage
		# Damage overflow from shield to health
		if shield < 0:
			health += shield
			shield = 0
	else:
		health -= damage
	# Die
	if health <= 0:
		die()

func die():
	tree.set("parameters/conditions/dead", true)
	collision_layer = 2
	input_ray_pickable = false
	for bone in bones:
		bone.collision_layer = 2
		bone.input_ray_pickable = false

func is_dead():
	return health <= 0

func recharge(is_max = false):
	shield += 1
	if is_max or shield > MAX_SHIELD:
		shield = MAX_SHIELD

func _on_recharge_delay_timeout() -> void:
	sfx.play(sfx.AUDIO.RECHARGE)
	tick.start()

func _on_recharge_tick_timeout() -> void:
	sfx.play(sfx.AUDIO.RECHARGE)
	recharge()
	if shield >= MAX_SHIELD:
		tick.stop()

func _on_shield_animation_finished(_anim_name: StringName) -> void:
	shield_anim.play("idle")
