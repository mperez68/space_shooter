extends Control

class_name menu_controller

enum MENU { NONE, CORE, IN_GAME, MAIN, CHARACTER_SELECT, MISSION_SELECT, SETTINGS }

@export var core_menu: MENU = MENU.MAIN
@export var fast_transition = false
@export var start_open = true

signal close

var active_menu: MENU = MENU.NONE
@onready var transitioning_menu: MENU = core_menu
@onready var timer = $FadeTimer

# Boot/Quit

func _ready():
	if start_open:
		start()
	else:
		stop()

func _on_fade_timer_timeout():
	_fade(transitioning_menu)
	
	# Update state
	active_menu = transitioning_menu
	transitioning_menu = MENU.NONE
	
func start():
	visible = true
	if fast_transition:
		_fast_transition(core_menu)
		transitioning_menu = MENU.NONE
		return
	timer.start()

func stop():
	if fast_transition:
		_fast_transition(MENU.NONE)
	visible = false

# Receivers

func close_menu() -> void:
	close.emit()
	stop()

func change_menu(new_menu: MENU):
	if active_menu == new_menu:
		return
	
	# Fast transition option
	if fast_transition:
		_fast_transition(new_menu);
		return
	
	# close current menu if any
	_fade(active_menu, false)
	
	# open new menu
	transitioning_menu = new_menu
	timer.start()

# Util

func _fade(key: MENU, is_fade_in = true):
	if get_menu(key) == null:
		return
	get_menu(key).fade(is_fade_in)

func _fast_transition(key: MENU):
	if get_menu(key) == null:
		active_menu = key;
		return
	if active_menu != MENU.NONE:
		get_menu(active_menu).fast_transition(false)
	get_menu(key).fast_transition(true)
	active_menu = key;

func get_menu(key: MENU):
	match key:
		MENU.CORE:
			if core_menu != key:
				return get_menu(core_menu)
			else:
				return null
		MENU.MAIN:
			return $Main
		MENU.CHARACTER_SELECT:
			return $CharSelect
		MENU.MISSION_SELECT:
			return $MissionSelect
		MENU.SETTINGS:
			return $Settings
		MENU.IN_GAME:
			return $InGame
		MENU.NONE:
			return null
