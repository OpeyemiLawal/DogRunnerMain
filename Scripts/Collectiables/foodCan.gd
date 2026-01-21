extends Node3D

@export var points = 5

const CollectibleVFX = preload("res://Scripts/VFX/CollectibleCollectionVFX.gd")

func _ready():
	# Connect the area signal if it exists
	var area = $Collectiable
	if area:
		area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if the player collected this item
	if body.name == "player" or body.is_in_group("player"):
		# Play professional collection VFX
		_play_collection_vfx()
		
		# Get the world generator to update points
		var world_gen = get_tree().get_first_node_in_group("world_generator")
		if world_gen and world_gen.has_method("update_points_display"):
			# Get current points and add this item's points
			var current_points = world_gen.current_points_collected
			world_gen.update_points_display(current_points + points)
		
		# Hide and remove the collectible
		queue_free()

func _play_collection_vfx():
	# Get world generator as parent for VFX
	var world_gen = get_tree().get_first_node_in_group("world_generator")
	if world_gen and world_gen.has_node("roadHolder"):
		var vfx = CollectibleVFX.create_collectible_vfx_at_position(
			global_position,
			world_gen.get_node("roadHolder"),
			CollectibleVFX.get_color_for_type("foodcan"),
			1.0,
			"foodcan"
		)
