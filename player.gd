extends CharacterBody3D

enum AUDIO{ JUMP, BOOST, LAND, SHOOT, WALKING }
enum STATE{ GROUND, RISING, FALLING }

const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 6.0
const AIRBORNE_MULTIPLIER = 3.0
const INERTIA_MULTIPLIER = 8.0
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5
const MAX_BOOSTS = 2

var speed = WALK_SPEED
var state = STATE.GROUND
var boosts = MAX_BOOSTS
var restart_walk = false

@export var sensitivity = 0.005
@export var gravity = 9.8

const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0
var last_bob_y = []

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready() -> void:
	# lock mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		if velocity.y < 0:
			change_state(STATE.FALLING)
	
	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			_audio(AUDIO.JUMP)
			change_state(STATE.RISING)
		elif boosts > 0:
			boosts -= 1
			velocity.y = JUMP_VELOCITY
			_audio(AUDIO.BOOST)
			change_state(STATE.RISING)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		change_state(STATE.GROUND)
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * INERTIA_MULTIPLIER)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * INERTIA_MULTIPLIER)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * AIRBORNE_MULTIPLIER)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * AIRBORNE_MULTIPLIER)
	
	velocity.limit_length(speed)
	
	# Head Bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# walk sound if bottom of walk bobbing wave
	if camera.transform.origin.y < -BOB_AMP * 0.9 and direction:
		_audio(AUDIO.WALKING)
		restart_walk = false
	if camera.transform.origin.y > BOB_AMP * 0.9 and direction:
		restart_walk = true
	
	# FOV
	var velocity_clamped = clamp(velocity.x, 0.5, SPRINT_SPEED * 4)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()

func change_state(new_state: STATE):
	if state == new_state:
		# no change
		return
	
	# do stuff on state change
	if state == STATE.GROUND and new_state == STATE.RISING:
		_audio(AUDIO.JUMP)
	
	if state == STATE.FALLING and new_state == STATE.GROUND:
		_audio(AUDIO.LAND)
		t_bob = 7*PI/8
		boosts = MAX_BOOSTS
	
	# update
	state = new_state

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = sin(time * BOB_FREQ / 2) * BOB_AMP
	
	return pos

func _audio(a: AUDIO, stop = false):
	var sel: AudioStreamPlayer3D
	match a:
		AUDIO.JUMP:
			sel = $Jump
		AUDIO.BOOST:
			sel = $Boost
		AUDIO.LAND:
			sel = $Land
		AUDIO.WALKING:
			if restart_walk:
				$Walk.stop()
			elif $Walk.is_playing():
				return
			sel = $Walk
	if (stop):
		sel.stop()
	else:
		sel.play()
