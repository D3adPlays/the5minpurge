extends LivingEntity

const JOYSTICK_DEADZONE = 0.2

@onready var weapon: Weapon = null

var aim_direction: Vector2 = Vector2.RIGHT
var last_movement_direction: Vector2 = Vector2.DOWN

func _on_ready() -> void:
	# Set up inherited animated sprite reference
	animated_sprite = $AnimatedSprite2D
	# Try to find the weapon node
	weapon = get_node_or_null("TomatoGun")
	add_to_group("player")
	if not weapon:
		push_error("No TomatoGun found as child of player. Weapon functionality will be disabled.")
		push_error("Add a TomatoGun node as a child of the Player node in the scene.")

func _physics_process(delta: float) -> void:
	handle_movement()
	handle_aim_direction()
	handle_attack()
	handle_animation()
	move_and_slide()
	handle_collisions()

func handle_movement() -> void:
	# Get input from WASD/Arrow keys or left joystick
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	
	# Normalize diagonal movement so speed is consistent
	input_vector = input_vector.normalized()
	
	# Update last movement direction if moving
	if input_vector != Vector2.ZERO:
		last_movement_direction = input_vector
	
	# Apply movement
	velocity = input_vector * move_speed

func handle_aim_direction() -> void:
	# Check for right joystick input first (gamepad has priority)
	var joystick_vector = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)
	
	# If joystick is being used (beyond deadzone), use it for aiming
	if joystick_vector.length() > JOYSTICK_DEADZONE:
		aim_direction = joystick_vector.normalized()
	else:
		# Otherwise, use mouse position for aiming
		var mouse_pos = get_global_mouse_position()
		aim_direction = (mouse_pos - global_position).normalized()

func handle_attack() -> void:
	# Attack with Space, Left Mouse Button, or gamepad button
	if Input.is_action_pressed("attack"):
		if weapon:
			weapon.attack(aim_direction)
		else:
			print("Cannot attack: No weapon equipped")

func handle_animation() -> void:
	if velocity.length() < 10:
		if abs(last_movement_direction.x) > abs(last_movement_direction.y):
			animated_sprite.play("idle-side")
			animated_sprite.flip_h = last_movement_direction.x < 0
		elif last_movement_direction.y < 0:
			animated_sprite.play("idle-up")
		else:
			animated_sprite.play("idle-down")
	else:
		# Play walk animations when moving
		if abs(last_movement_direction.x) > abs(last_movement_direction.y):
			animated_sprite.play("walk-right")
			animated_sprite.flip_h = last_movement_direction.x < 0
		elif last_movement_direction.y < 0:
			animated_sprite.play("walk-up")
		else:
			animated_sprite.play("walk-down")

func handle_collisions() -> void:
	# Handle collisions after move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is RigidBody2D:
			var push_force = 100.0
			var push_direction = collision.get_normal() * -1
			collider.apply_central_impulse(push_direction * push_force * get_physics_process_delta_time())
		
		elif collider is CharacterBody2D:
			if collider.is_in_group("enemies"):
				pass
		
		elif collider is StaticBody2D or collider is TileMap:
			pass
		
		elif collider is Area2D:
			if collider.is_in_group("items"):
				pass
