extends Control


@onready var quit_button = $Menu/QuitPanel/Control/Quit
@onready var start_overlay = $Menu/Buttons/VBoxContainer/ProfileBtn  # Optional "Tap to Start" Control
@onready var profile_panel: Control = $Menu/ProfilePanel
@onready var quit_panel: Control = $Menu/QuitPanel

@onready var bg: Sprite2D = $Menu/Sprite2D
@export var speed := 100.0
var is_game_paused = false

func _ready() -> void:
	# Remove white outline from all buttons
	for child in get_children():
		if child is Button:
			child.focus_mode = Control.FOCUS_NONE

	# Pause the game until first user gesture
	if OS.get_name() == "HTML5":
		get_tree().paused = true
		start_overlay.visible = true
		start_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
		start_overlay.connect("gui_input", Callable(self, "_on_first_interaction"))

	# Start splash animation
	$SplashScreen/AnimationPlayer.play("Splash")


	 #Connect button signals
	
	
	
func _process(delta: float) -> void:
	pass
	
# Called on first click/tap
func _on_first_interaction(event):
	if event is InputEventMouseButton and event.pressed:
		start_overlay.hide()
		get_tree().paused = false  # Resume the tree and audio automatically

func _on_play_pressed() -> void:
	# Normal play button pressed
	get_tree().change_scene_to_file("res://Scenes/World1.tscn")

func _on_quit_pressed() -> void:
	pass
	#get_tree().quit()

func _on_profile_pressed() -> void:
	is_game_paused = true
	profile_panel.visible = true

func _on_exit_profile_pressed() -> void:
	is_game_paused = false
	profile_panel.visible = false


func _on_exit_btn_pressed() -> void:
	is_game_paused = true
	quit_panel.visible = true


func _on_cancel_pressed() -> void:
	is_game_paused = false
	quit_panel.visible = false


func _on_splash_finished(_anim_name):
	$Menu.visible = true
	$SplashScreen.visible = false
	$Menu/BgAnimPlayer.play("BackgroundAnim")
	$Menu/DogAnimPlayer.play("Anim")
