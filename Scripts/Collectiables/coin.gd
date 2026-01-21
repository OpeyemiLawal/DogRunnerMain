extends Area3D

const CollectibleVFX = preload("res://Scripts/VFX/CollectibleCollectionVFX.gd")

func _ready():
	# Connect the area signal
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node3D) -> void:
	# Check if the body is the player
	if body.name == "player" or body.is_in_group("player"):
		# Play professional collection VFX
		_play_collection_vfx()
		
		# Get the world generator to update coins
		var world_gen = get_tree().get_first_node_in_group("world_generator")
		if world_gen and world_gen.has_method("update_coin_display"):
			# Get current coins and add 1
			var current_coins = world_gen.current_coins_collected
			world_gen.update_coin_display(current_coins + 1)
		
		# Remove the coin
		queue_free()

func _play_collection_vfx():
	# Get world generator as parent for VFX
	var world_gen = get_tree().get_first_node_in_group("world_generator")
	if world_gen and world_gen.has_node("roadHolder"):
		var vfx = CollectibleVFX.create_collectible_vfx_at_position(
			global_position,
			world_gen.get_node("roadHolder"),
			CollectibleVFX.get_color_for_type("coin"),
			1.0,
			"coin"
		)
