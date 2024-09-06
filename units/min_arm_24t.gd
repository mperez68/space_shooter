extends AbstractMecha

@export var player_path: NodePath

@onready var nav_agent = $NavigationAgent3D

enum DIRECTION { NONE, FORWARD, LEFT, RIGHT, BACK }

var player = null
var aggro_range = [20, 50]
var aggro = false
var direction_state = DIRECTION.NONE

# Lore notes: Minarm24t: Minimal Armament Drone, 24 ton. Remote piloted with
# diode-based onboard AI to account for latency failures. Primitive compared to 
# Standard quantum-machine AI "war-minds" but a fraction of the cost.

func _ready() -> void:
	super()
	
	if (get_node(player_path) != null):
		player = get_node(player_path)
		nav_agent.set_target_position(player.global_position)

func _physics_process(delta: float) -> void:
	super(delta)
	
	if !is_dead() and player != null:
		nav_agent.set_target_position(player.global_position)
		var next_nav_point = nav_agent.get_next_path_position()
		var move = (next_nav_point - global_position).normalized() * speed
		
		# Distance between self and player
		var d = global_position.distance_to(player.global_position)
		
		# Aggro if in range
		if !aggro and d < aggro_range[1]:
			aggro = true
			print("aggro ", name)
		
		# Only approach if aggro is on
		if aggro:
			if d > aggro_range[0]:
				print("forward")
				direction_state = DIRECTION.FORWARD
			# Start Strafe
			if (direction_state == DIRECTION.FORWARD and d <= aggro_range[0]):
				print("right")
				direction_state = DIRECTION.RIGHT
			## Switch strafe direction if blocked
			if direction_state == DIRECTION.RIGHT and $RightRayCast.is_colliding():
				print("left")
				direction_state = DIRECTION.LEFT
			if direction_state == DIRECTION.LEFT and $LeftRayCast.is_colliding():
				print("right")
				direction_state = DIRECTION.RIGHT
			## If stuck between two things, stop
			if $RightRayCast.is_colliding() and $LeftRayCast.is_colliding():
				print("stop")
				direction_state = DIRECTION.NONE
		
		# move based on current state
		var new_move = get_move_from_state(move)
		velocity.x = new_move.x
		velocity.z = new_move.z
		animate(get_anim_from_state())
		
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	if !is_dead() or !is_on_floor():
		move_and_slide()

func get_move_from_state(move: Vector3) -> Vector3:
	var ret = Vector3.ZERO
	
	match direction_state:
		DIRECTION.FORWARD:
			ret = move
		DIRECTION.LEFT:
			ret = move.rotated(Vector3.UP, deg_to_rad(90))
		DIRECTION.RIGHT:
			ret = move.rotated(Vector3.UP, deg_to_rad(-90))
	
	return ret

func get_anim_from_state() -> Vector2:
	var ret = Vector2.ZERO
	
	match direction_state:
		DIRECTION.FORWARD:
			ret = Vector2(0, -1)
		DIRECTION.LEFT:
			ret = Vector2(-1, 0)
		DIRECTION.RIGHT:
			ret = Vector2(1, 0)
	
	return ret

func hit(damage: int) -> void:
	super(damage)
	if !aggro:
		aggro = true
		print("hit(): aggro ", name)
