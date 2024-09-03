extends AbstractMecha

@export var player_path: NodePath

@onready var nav_agent = $NavigationAgent3D

var player = null
var target_range = [6, 20]

# Lore notes: Minarm24t: Minimal Armament Drone, 24 ton. Remote piloted with
# diode-based onboard AI to account for latency failures. Primitive compared to 
# Standard quantum-machine AI "war-minds" but a fraction of the cost.

func _ready() -> void:
	super()
	
	player = get_node(player_path)
	nav_agent.set_target_position(player.global_position)

func _physics_process(delta: float) -> void:
	super(delta)
	
	if is_dead():
		return
	
	nav_agent.set_target_position(player.global_position)
	var next_nav_point = nav_agent.get_next_path_position()
	var move = (next_nav_point - global_position).normalized() * speed
	
	var d = global_position.distance_to(player.global_position)
	if (d > target_range[0] and d < target_range[1]):
		velocity.x = move.x
		velocity.z = move.z
		animate(Vector2(0, -1))
	else:
		velocity.x = 0
		velocity.z = 0
		animate(Vector2.ZERO)
	
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	
	move_and_slide()
