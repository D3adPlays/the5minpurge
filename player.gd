extends CharacterBody2D

const SPEED = 300.0
const JOYSTICK_DEADZONE = 0.2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var aim_direction: Vector2 = Vector2.RIGHT
var last_movement_direction: Vector2 = Vector2.DOWN

func _physics_process(delta: float) -> void:
	handle_movement()
	handle_aim_direction()
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
	velocity = input_vector * SPEED

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

func handle_animation() -> void:
	if velocity.length() < 10:
		# Play idle animations when not moving
		if abs(last_movement_direction.x) > abs(last_movement_direction.y):
			# Last moved horizontally
			animated_sprite.play("idle-side")
			animated_sprite.flip_h = last_movement_direction.x < 0
		elif last_movement_direction.y < 0:
			# Last moved up
			animated_sprite.play("idle-up")
		else:
			# Last moved down
			animated_sprite.play("idle-down")
	else:
		# Play walk animations when moving
		if abs(last_movement_direction.x) > abs(last_movement_direction.y):
			# Moving horizontally
			animated_sprite.play("walk-right")
			animated_sprite.flip_h = last_movement_direction.x < 0
		elif last_movement_direction.y < 0:
			# Moving up
			animated_sprite.play("walk-up")
		else:
			# Moving down
			animated_sprite.play("walk-down")

func handle_collisions() -> void:
	# Handle collisions after move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Check what we collided with and respond accordingly
		if collider is RigidBody2D:
			# Push rigid bodies (like barrels, crates, etc.)
			var push_force = 100.0
			var push_direction = collision.get_normal() * -1
			collider.apply_central_impulse(push_direction * push_force * get_physics_process_delta_time())
		
		elif collider is CharacterBody2D:
			# Handle collision with other characters (enemies, NPCs)
			if collider.is_in_group("enemies"):
				# Take damage or handle enemy collision
				pass
		
		elif collider is StaticBody2D or collider is TileMap:
			# Collided with walls or static environment
			# move_and_slide() already handles sliding along walls
			pass
		
		elif collider is Area2D:
			# Handle area interactions (triggers, pickups, etc.)
			if collider.is_in_group("items"):
				# Handle item pickup
				pass
