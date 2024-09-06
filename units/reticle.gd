extends CenterContainer

@export var DOT_RADIUS = 1.0
@export var DOT_COLOR = Color.WHITE
@export var HIT_COLOR = Color.RED

@onready var lines = [$Top, $Bottom, $Left, $Right]
@onready var timer = $Timer

func _ready():
	queue_redraw()

func _draw():
	draw_circle(Vector2(0,0), DOT_RADIUS, DOT_COLOR)

func hit():
	for line in lines:
		line.default_color = HIT_COLOR
	
	timer.start()

func _on_timer_timeout() -> void:
	for line in lines:
		line.default_color = DOT_COLOR
