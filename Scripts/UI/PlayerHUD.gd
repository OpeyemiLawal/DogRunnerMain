extends Control

@onready var health_label: Label = $HealthHUD/HealthLabel
@onready var coin_label: Label = $TextureRect/CoinLabel

# Health bar segments
@onready var health_hud: TextureRect = $HealthHUD


var player: CharacterBody3D
var world_generator: Node

func _ready():
	# Find the player and world generator
	player = get_tree().get_first_node_in_group("player")
	world_generator = get_tree().get_first_node_in_group("world_generator")
	
	if player:
		# Connect to player signals if they exist
		if player.has_signal("health_changed"):
			player.health_changed.connect(_on_health_changed)
	
	# Update display every frame
	set_process(true)

func _process(delta):
	if player:
		update_health_display()
		# Don't update coin display every frame - it's handled by WorldGenerator

func update_health_display():
	if player and health_label:
		var health = player.get("health") if player.has_method("get") else 100
		health_label.text = str(health) 
		
		
		# Change color based on health
		#if health <= 30:
			#health_label.modulate = Color.RED
		#elif health <= 60:
			#health_label.modulate = Color.YELLOW
		#else:
			#health_label.modulate = Color.GREEN


func _on_health_changed(new_health: int):
	update_health_display()

func reset_hud():
	if player:
		update_health_display()

func update_coin_display():
	 #This method is no longer used - points are handled by WorldGenerator
	# Keeping for compatibility but not doing anything
	pass

func update_all_displays():
	update_health_display()
	update_coin_display()

func set_coin_display(coin_count: int):
	if coin_label:
		coin_label.text = str(coin_count)
		coin_label.modulate = Color.WHITE
