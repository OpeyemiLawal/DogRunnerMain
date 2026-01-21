extends Node3D

# Particle systems
@onready var burst_particles: GPUParticles3D = $BurstParticles
@onready var sparkle_particles: GPUParticles3D = $SparkleParticles
@onready var trail_particles: GPUParticles3D = $TrailParticles

# Lighting
@onready var flash_light: OmniLight3D = $FlashLight
@onready var ambient_light: OmniLight3D = $AmbientLight

# Audio
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

# Visual elements
@onready var scale_node: Node3D = $ScaleNode
@onready var glow_mesh: MeshInstance3D = $ScaleNode/GlowMesh

# VFX Configuration
var vfx_color: Color = Color(1.0, 0.843, 0.0, 1.0)  # Default gold
var vfx_intensity: float = 1.0
var collectible_type: String = "default"

# Sound configuration
var collect_sound: AudioStream

func _ready():
	# Load collection sound
	_load_collection_sound()
	
	# Set initial states
	_setup_initial_states()

func _setup_initial_states():
	# Hide glow mesh initially
	if glow_mesh:
		glow_mesh.visible = false
	
	# Set light to off initially
	if flash_light:
		flash_light.light_energy = 0.0
	if ambient_light:
		ambient_light.light_energy = 0.0

func _load_collection_sound():
	# Try to load collection sound
	var sound_paths = [
		"res://Assets/Audio/coin-collected.mp3",
		"res://Assets/Audio/coin_collect.wav",
		"res://Assets/Audio/collectible_pickup.ogg"
	]
	
	for path in sound_paths:
		if ResourceLoader.exists(path):
			collect_sound = load(path)
			if audio:
				audio.stream = collect_sound
			break

# Main function to play collection VFX
func play_collection_vfx(color: Color = Color(1.0, 0.843, 0.0, 1.0), intensity: float = 1.0, type: String = "default"):
	vfx_color = color
	vfx_intensity = intensity
	collectible_type = type
	
	# Configure particle colors
	_configure_particles()
	
	# Play all effects
	_play_particle_effects()
	_play_light_effects()
	_play_scale_animation()
	_play_sound_effect()
	
	# Auto-cleanup
	_start_cleanup_timer()

func _configure_particles():
	# Configure burst particles with color
	if burst_particles:
		var material = burst_particles.process_material as ParticleProcessMaterial
		if material:
			material.color = vfx_color
			material.color_ramp = _create_color_ramp(vfx_color)
	
	# Configure sparkle particles
	if sparkle_particles:
		var material = sparkle_particles.process_material as ParticleProcessMaterial
		if material:
			var sparkle_color = vfx_color.lerp(Color.WHITE, 0.3)
			material.color = sparkle_color
	
	# Configure trail particles
	if trail_particles:
		var material = trail_particles.process_material as ParticleProcessMaterial
		if material:
			material.color = vfx_color

func _create_color_ramp(base_color: Color) -> Gradient:
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([
		base_color,
		base_color.lerp(Color.WHITE, 0.5),
		base_color.lerp(Color(1, 1, 1, 0), 0.8),
		Color(1, 1, 1, 0)
	])
	gradient.offsets = PackedFloat32Array([0.0, 0.3, 0.7, 1.0])
	return gradient

func _play_particle_effects():
	# Play burst particles (explosive effect)
	if burst_particles:
		burst_particles.restart()
		burst_particles.emitting = true
	
	# Play sparkle particles (magical sparkles)
	if sparkle_particles:
		sparkle_particles.restart()
		sparkle_particles.emitting = true
	
	# Play trail particles (upward trail)
	if trail_particles:
		trail_particles.restart()
		trail_particles.emitting = true

func _play_light_effects():
	# Flash light (quick bright flash)
	if flash_light:
		flash_light.light_color = vfx_color
		flash_light.light_energy = 0.0
		
		var tween = create_tween()
		tween.set_parallel(true)
		
		# Intensity flash
		flash_light.light_energy = 4.0 * vfx_intensity
		tween.tween_property(flash_light, "light_energy", 0.0, 0.4).set_ease(Tween.EASE_OUT)
		
		# Color pulse
		var pulse_color = vfx_color.lerp(Color.WHITE, 0.5)
		tween.tween_property(flash_light, "light_color", pulse_color, 0.2)
		tween.tween_property(flash_light, "light_color", vfx_color, 0.2)
	
	# Ambient light (softer, longer glow)
	if ambient_light:
		ambient_light.light_color = vfx_color
		ambient_light.light_energy = 0.0
		
		var tween = create_tween()
		tween.set_parallel(true)
		
		# Gentle glow
		ambient_light.light_energy = 2.0 * vfx_intensity
		tween.tween_property(ambient_light, "light_energy", 0.0, 0.8).set_ease(Tween.EASE_OUT)

func _play_scale_animation():
	# Pop animation effect
	if scale_node:
		scale_node.scale = Vector3.ZERO
		
		var tween = create_tween()
		tween.set_parallel(true)
		
		# Pop out
		tween.tween_property(scale_node, "scale", Vector3(1.5, 1.5, 1.5) * vfx_intensity, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		# Pop back
		tween.tween_property(scale_node, "scale", Vector3(0.8, 0.8, 0.8), 0.1).set_delay(0.15)
		# Fade out
		tween.tween_property(scale_node, "scale", Vector3.ZERO, 0.25).set_delay(0.25)
		
		# Show glow mesh during animation
		if glow_mesh:
			glow_mesh.visible = true
			var glow_tween = create_tween()
			if glow_mesh.material_override:
				var mat = glow_mesh.material_override as StandardMaterial3D
				if mat:
					mat.albedo_color = vfx_color
					mat.emission_enabled = true
					mat.emission = vfx_color
					mat.emission_energy_multiplier = 2.0
					
					glow_tween.tween_property(mat, "emission_energy_multiplier", 0.0, 0.4)
					glow_tween.tween_callback(func(): glow_mesh.visible = false)

func _play_sound_effect():
	if audio and audio.stream:
		# Handle HTML5 audio context
		if OS.get_name() == "HTML5":
			JavaScriptBridge.eval("""
				if (typeof window.godot_audio_resume === 'function') {
					window.godot_audio_resume();
				}
			""")
			await get_tree().create_timer(0.05).timeout
		
		# Pitch variation for variety
		audio.pitch_scale = randf_range(0.95, 1.05)
		audio.volume_db = linear_to_db(vfx_intensity)
		audio.play()

func _start_cleanup_timer():
	# Cleanup after all effects complete
	var cleanup_timer = Timer.new()
	add_child(cleanup_timer)
	cleanup_timer.wait_time = 2.5  # Give enough time for all effects
	cleanup_timer.one_shot = true
	cleanup_timer.timeout.connect(_cleanup_vfx)
	cleanup_timer.start()

func _cleanup_vfx():
	# Stop all particles
	if burst_particles:
		burst_particles.emitting = false
	if sparkle_particles:
		sparkle_particles.emitting = false
	if trail_particles:
		trail_particles.emitting = false
	
	# Remove VFX node
	queue_free()

# Static method to create and play VFX at position
static func create_collectible_vfx_at_position(
	position: Vector3, 
	parent_node: Node, 
	color: Color = Color(1.0, 0.843, 0.0, 1.0),
	intensity: float = 1.0,
	type: String = "default"
) -> Node3D:
	var vfx_scene = preload("res://Scenes/VFX/CollectibleCollectionVFX.tscn")
	if not vfx_scene:
		push_error("CollectibleCollectionVFX.tscn not found!")
		return null
	
	var vfx_instance = vfx_scene.instantiate()
	
	# Add to parent and set position
	parent_node.add_child(vfx_instance)
	vfx_instance.global_position = position
	
	# Play the effects
	vfx_instance.play_collection_vfx(color, intensity, type)
	
	return vfx_instance

# Preset colors for different collectible types
static func get_color_for_type(type: String) -> Color:
	match type.to_lower():
		"coin":
			return Color(1.0, 0.843, 0.0, 1.0)  # Gold
		"bone":
			return Color(0.6, 0.2, 0.8, 1.0)  # Purple
		"collar":
			return Color(1.0, 0.2, 0.2, 1.0)  # Red
		"collar2":
			return Color(0.8, 0.4, 0.9, 1.0)  # Pink Blue (pinkish blue)
		"foodcan":
			return Color(0.3, 0.3, 0.3, 1.0)  # Dark Ash (dark gray)
		"tennisball":
			return Color(0.2, 1.0, 0.3, 1.0)  # Green
		_:
			return Color(1.0, 0.843, 0.0, 1.0)  # Default gold

