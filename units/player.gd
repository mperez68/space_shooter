extends AbstractMecha

const BOOST_VELOCITY = 18.0
const MAX_BOOSTS = 2

var boosts = 0
var restart_walk = false

const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

var slug = load("res://units/guns/laser.tscn")
var slug_instance

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var gun = $Head/Camera3D/Rifle/AnimationPlayer
@onready var gun_barrel = $Head/Camera3D/Rifle/RayCast3D


func _ready() -> void:
	super()
	
	# lock mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		body.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		body_parts[1].rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	if event.is_action_pressed("shoot"):
		if !gun.is_playing():
			gun.play("shoot")
			slug_instance = slug.instantiate()
			slug_instance.position = gun_barrel.global_position
			slug_instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(slug_instance)
			

# HUD/general tracking
func _process(_delta: float) -> void:
	$HUD.getBoostBar().value = $HUD.getBoostBar().max_value -($HUD.getBoostBar().max_value * ($BoostTimer.time_left / $BoostTimer.wait_time))

# Controls/physics
func _physics_process(delta: float) -> void:
	super(delta)
	
	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	animate(input_dir)
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * INERTIA_MULTIPLIER)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * INERTIA_MULTIPLIER)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * AIRBORNE_MULTIPLIER)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * AIRBORNE_MULTIPLIER)
	
	# Cap speed
	velocity.limit_length(speed)

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			jump()
		elif boosts > 0:
			boosts -= 1
			jump(true)
	
	# Handle Strafe boost.
	var strafe = Vector3(0, 0, 0)
	if Input.is_action_just_pressed("strafe_left"):
		strafe = (head.transform.basis * Vector3(-1, 0, 0)).normalized()
	elif Input.is_action_just_pressed("strafe_right"):
		strafe = (head.transform.basis * Vector3(1, 0, 0)).normalized()
	if strafe.length() > 0 and boosts > 0:
		velocity.y += JUMP_VELOCITY / 3
		velocity.x += strafe.x * BOOST_VELOCITY
		velocity.z += strafe.z * BOOST_VELOCITY
		boosts -= 1
		change_state(STATE.RISING)
		sfx.play(sfx.AUDIO.BOOST)
		
	
	# Head Bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# walk sound if bottom of walk bobbing wave
	if camera.transform.origin.y < -BOB_AMP * 0.9 and direction:
		sfx.play(sfx.AUDIO.WALKING)
		restart_walk = false
	if camera.transform.origin.y > BOB_AMP * 0.9 and direction:
		restart_walk = true

	move_and_slide()

func jump(boost: bool = false):
	if boost:
		sfx.play(sfx.AUDIO.BOOST)
	velocity.y = JUMP_VELOCITY
	change_state(STATE.RISING)

func _change_state(new_state: STATE):
	super(new_state)
	
	# do stuff on state change
	if state == STATE.GROUND and new_state == STATE.RISING:
		if !$BoostTimer.is_stopped():
			$BoostTimer.stop()
	
	if state == STATE.FALLING and new_state == STATE.GROUND:
		t_bob = 7*PI/8
		if $BoostTimer.is_stopped() and boosts != MAX_BOOSTS:
			$BoostTimer.start()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = sin(time * BOB_FREQ / 2) * BOB_AMP
	
	return pos

func _on_boost_timer_timeout():
	boosts = MAX_BOOSTS
