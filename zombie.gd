extends LivingEntity

@export var patrol_speed: float = 100.0
@export var chase_speed: float = 150.0
@export var attack_damage: float = 15.0
@export var detection_range: float = 300.0

var player: Node2D = null
var state: String = "idle"  # idle, patrol, chase, attack

func _on_ready() -> void:
	# Set up zombie properties
	add_to_group("enemies")
	max_health = 50.0
	current_health = max_health
	move_speed = patrol_speed
	animated_sprite = $AnimatedSprite2D
	collision_shape = $CollisionShape2D

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	# AI logic here (chase player, patrol, etc.)
	handle_ai()

func handle_ai() -> void:
	# Your zombie AI logic
	## move towards player if within detection range, otherwise patrol
	

	pass

func _on_death() -> void:
	# Custom death behavior for zombies
	if animated_sprite:
		animated_sprite.play("death")
	if collision_shape:
		collision_shape.disabled = true
	# Optional: drop items, play sound, etc.
	await get_tree().create_timer(2.0).timeout
	queue_free()