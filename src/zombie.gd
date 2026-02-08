extends Enemy

## Zombie enemy - a slow but persistent melee attacker

func _on_ready() -> void:
	# Call parent to ensure zombie is added to "enemies" group
	super._on_ready()
	
	# Set up zombie-specific properties
	max_health = 30.0
	current_health = max_health
	
	# Movement speeds
	patrol_speed = 80.0
	chase_speed = 120.0
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

func _on_enemy_ready() -> void:
	# Additional zombie-specific setup after enemy initialization
	pass

func die():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("modify_timer"):
		player.modify_timer(7.0) # +7 secondes à la mort du zombie
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
