extends LivingEntity
class_name Enemy

## Base class for all enemies
## Provides common functionality for AI, player tracking, and enemy behavior

## AI States
enum State { IDLE, PATROL, CHASE, ATTACK }

## Movement properties
@export var patrol_speed: float = 100.0
@export var chase_speed: float = 150.0

## Combat properties
@export var attack_damage: float = 10.0
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1.0

## Detection and AI
@export var detection_range: float = 800.0
@export var lose_sight_range: float = 1200.0

## Current AI state
var state: State = State.IDLE

## Reference to the player
var player: Node2D = null

## Navigation
var navigation_agent: NavigationAgent2D = null

## Attack timer
var can_attack: bool = true
var attack_timer: float = 0.0

func _on_ready() -> void:
	add_to_group("enemies")
	
	# Set up navigation agent if it exists
	if has_node("NavigationAgent2D"):
		navigation_agent = get_node("NavigationAgent2D")
	
	# Wait for navigation to be ready
	call_deferred("_enemy_setup")

func _enemy_setup() -> void:
	# Wait for the first physics frame so the NavigationServer can sync
	await get_tree().physics_frame
	
	# Find the player
	player = get_player()
	
	# Allow child classes to do additional setup
	_on_enemy_ready()

## Override this in child classes for custom enemy initialization
func _on_enemy_ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	# Update attack cooldown
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true
	
	# Handle AI behavior
	handle_ai(delta)
	
	# Apply movement
	move_and_slide()

## Main AI logic - can be overridden by child classes
func handle_ai(delta: float) -> void:
	if not player or not player.is_inside_tree():
		player = get_player()
		if not player:
			idle_behavior(delta)
			return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Determine state based on distance
	if distance_to_player > lose_sight_range:
		change_state(State.IDLE)
	elif distance_to_player <= attack_range:
		change_state(State.ATTACK)
	elif distance_to_player <= detection_range:
		change_state(State.CHASE)
	else:
		change_state(State.IDLE)
	
	# Execute behavior based on state
	match state:
		State.IDLE:
			idle_behavior(delta)
		State.PATROL:
			patrol_behavior(delta)
		State.CHASE:
			chase_behavior(delta)
		State.ATTACK:
			attack_behavior(delta)

## Change the enemy's state
func change_state(new_state: State) -> void:
	if state == new_state:
		return
	
	var old_state = state
	state = new_state
	_on_state_changed(old_state, new_state)

## Override this to respond to state changes
func _on_state_changed(old_state: State, new_state: State) -> void:
	pass

## Idle behavior - standing still or wandering
func idle_behavior(delta: float) -> void:
	velocity = velocity.lerp(Vector2.ZERO, 0.1)
	move_speed = patrol_speed

## Patrol behavior - override in child classes for custom patrol patterns
func patrol_behavior(delta: float) -> void:
	velocity = velocity.lerp(Vector2.ZERO, 0.1)

## Chase behavior - pursue the player
func chase_behavior(delta: float) -> void:
	if not player or not navigation_agent:
		return
	
	move_speed = chase_speed
	navigation_agent.target_position = player.global_position
	
	# Get the next position from the navigation agent
	if navigation_agent.is_navigation_finished():
		velocity = velocity.lerp(Vector2.ZERO, 0.2)
		return
	
	var next_path_position = navigation_agent.get_next_path_position()
	var direction = (next_path_position - global_position).normalized()
	
	# Move towards the next path position
	velocity = direction * move_speed
	
	# Face the direction of movement
	_face_direction(direction)

## Attack behavior - attack the player
func attack_behavior(delta: float) -> void:
	if not player:
		return
	
	# Face the player
	var direction = (player.global_position - global_position).normalized()
	_face_direction(direction)
	
	# Stop moving when attacking
	velocity = velocity.lerp(Vector2.ZERO, 0.2)
	
	# Perform attack
	if can_attack:
		perform_attack()

## Perform an attack - override in child classes for custom attacks
func perform_attack() -> void:
	if not player or not can_attack:
		return
	
	can_attack = false
	attack_timer = attack_cooldown
	
	# Check if player is still in range
	var distance = global_position.distance_to(player.global_position)
	if distance <= attack_range:
		# Deal damage to player if it has the take_damage method
		if player.has_method("take_damage"):
			player.take_damage(attack_damage, self)
	
	# Allow child classes to add custom attack behavior
	_on_attack_performed()

## Override this for custom attack effects (animations, sounds, etc.)
func _on_attack_performed() -> void:
	pass

## Face a specific direction (flip sprite, etc.)
func _face_direction(direction: Vector2) -> void:
	if animated_sprite and direction.x != 0:
		animated_sprite.flip_h = direction.x < 0

## Override death behavior for enemies
func _on_death() -> void:
	# Remove from enemies group
	remove_from_group("enemies")
	
	# Play death animation if available
	if animated_sprite:
		if animated_sprite.sprite_frames.has_animation("death"):
			animated_sprite.play("death")
			await animated_sprite.animation_finished
		else:
			# Fade out if no death animation
			var tween = create_tween()
			tween.tween_property(animated_sprite, "modulate:a", 0.0, 0.5)
			await tween.finished
	
	# Disable collision
	if collision_shape:
		collision_shape.disabled = true
	
	# Allow child classes to add custom death behavior
	_on_enemy_death()
	
	# Clean up
	queue_free()

## Override this for custom enemy death behavior (loot drops, effects, etc.)
func _on_enemy_death() -> void:
	pass
