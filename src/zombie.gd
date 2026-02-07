extends LivingEntity

@export var patrol_speed: float = 100.0
@export var chase_speed: float = 150.0
@export var attack_damage: float = 15.0
@export var detection_range: float = 900.0

var player: Node2D = null
var state: String = "idle"  # idle, patrol, chase, attack
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _on_ready() -> void:
	# Set up zombie properties
	add_to_group("enemies")
	max_health = 50.0
	current_health = max_health
	move_speed = patrol_speed
	animated_sprite = $AnimatedSprite2D
	collision_shape = $CollisionShape2D
	
	# Wait for navigation to be ready
	call_deferred("actor_setup")

func actor_setup() -> void:
	# Wait for the first physics frame so the NavigationServer can sync
	await get_tree().physics_frame
	# Find the player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	# AI logic here (chase player, patrol, etc.)
	handle_ai()
	move_and_slide()

func handle_ai() -> void:
	if not player:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# If player is within detection range, pathfind towards them
	if distance_to_player < detection_range:
		state = "chase"
		move_speed = chase_speed
		navigation_agent.target_position = player.global_position
		
		# Get the next position from the navigation agent
		if navigation_agent.is_navigation_finished():
			return
		
		var next_path_position = navigation_agent.get_next_path_position()
		var direction = (next_path_position - global_position).normalized()
		
		# Move towards the next path position
		velocity = direction * move_speed
	else:
		state = "idle"
		move_speed = patrol_speed
		velocity = Vector2.ZERO

func _on_death() -> void:
	# Custom death behavior for zombies
	if animated_sprite:
		animated_sprite.play("death")
	if collision_shape:
		collision_shape.disabled = true
	# Optional: drop items, play sound, etc.
	await get_tree().create_timer(2.0).timeout
	queue_free()