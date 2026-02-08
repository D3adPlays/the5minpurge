extends Enemy

## Zombie enemy - a slow but persistent melee attacker

@onready var sound_player: AudioStreamPlayer2D = null

var sound_timer: float = 0.0
var sound_interval: float = 10.0

func _on_ready() -> void:
	# Call parent to ensure zombie is added to "enemies" group
	super._on_ready()
	
	# Set up zombie-specific properties
	max_health = 30.0
	current_health = max_health
	
	# Movement speeds
	patrol_speed = 80.0
	chase_speed = 200.0
	move_speed = patrol_speed
	
	# Combat properties
	attack_damage = 15.0
	attack_range = 60.0
	attack_cooldown = 1.5
	
	# Detection
	detection_range = 900.0
	lose_sight_range = 1200.0
	
	# Set up sprite and collision
	animated_sprite = $AnimatedSprite2D
	collision_shape = $CollisionShape2D
	navigation_agent = $NavigationAgent2D
	
	# Set up sound player
	sound_player = get_node_or_null("ZombieSound")
	print("[Zombie] Sound setup - ZombieSound node: ", sound_player)
	
	# Check for individual sound nodes and disable autoplay
	for i in range(1, 4):
		var sound_node = get_node_or_null("Zombie" + str(i))
		print("[Zombie] Sound node Zombie", i, ": ", sound_node)
		if sound_node and sound_node is AudioStreamPlayer2D:
			sound_node.autoplay = false  # Disable autoplay so script can control it
			sound_node.stop()  # Stop any currently playing sound
			print("[Zombie]   - Has stream: ", sound_node.stream != null)
			print("[Zombie]   - Volume: ", sound_node.volume_db, " dB")
	
	sound_timer = randf_range(0.0, sound_interval)
	print("[Zombie] Sound timer initialized with offset: ", sound_timer)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	# Handle sound playing
	if is_alive:
		sound_timer += delta
		if sound_timer >= sound_interval:
			sound_timer = 0.0
			print("[Zombie ", name, "] Attempting to play sound")
			play_random_zombie_sound()

func _on_enemy_ready() -> void:
	# Additional zombie-specific setup after enemy initialization
	pass

func die():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("modify_timer"):
		player.modify_timer(7.0)
	queue_free()

func _on_state_changed(old_state: State, new_state: State) -> void:
	# Update animations based on state changes
	if not animated_sprite:
		return
	
	match new_state:
		State.IDLE:
			if animated_sprite.sprite_frames.has_animation("idle"):
				animated_sprite.play("idle")
		State.CHASE:
			if animated_sprite.sprite_frames.has_animation("walk"):
				animated_sprite.play("walk")
		State.ATTACK:
			if animated_sprite.sprite_frames.has_animation("attack"):
				animated_sprite.play("attack")

func play_random_zombie_sound() -> void:
	# Pick a random zombie sound (1, 2, or 3)
	var sound_number = randi_range(1, 3)
	var sound_node_name = "Zombie" + str(sound_number)
	print("[Zombie ", name, "] Trying to play sound: ", sound_node_name)
	
	# Randomize pitch slightly (0.9 to 1.1)
	var random_pitch = randf_range(0.9, 1.1)
	
	# Try to find specific sound player (Zombie1, Zombie2, or Zombie3)
	var specific_player = get_node_or_null(sound_node_name)
	if specific_player and specific_player is AudioStreamPlayer2D:
		print("[Zombie ", name, "] Found specific player: ", sound_node_name)
		print("[Zombie ", name, "] Has stream: ", specific_player.stream != null)
		print("[Zombie ", name, "] Volume: ", specific_player.volume_db)
		if specific_player.stream:
			specific_player.pitch_scale = random_pitch
			specific_player.play()
			print("[Zombie ", name, "] Playing sound from ", sound_node_name, " with pitch: ", random_pitch)
		return
	
	# Fallback to generic sound player
	print("[Zombie ", name, "] Falling back to generic ZombieSound player")
	if sound_player and sound_player.stream:
		sound_player.pitch_scale = random_pitch
		sound_player.play()
		print("[Zombie ", name, "] Playing from ZombieSound with pitch: ", random_pitch)
	else:
		print("[Zombie ", name, "] WARNING: No sound player found or no stream assigned!")

func _on_attack_performed() -> void:
	# Play attack sound or animation
	if animated_sprite and animated_sprite.sprite_frames.has_animation("attack"):
		animated_sprite.play("attack")

func _on_enemy_death() -> void:
	# Custom zombie death behavior
	# Add 5 seconds to player's timer on zombie kill
	var player_node = get_player()
	if player_node and player_node.has_method("modify_timer"):
		player_node.modify_timer(7.0)
