extends LivingEntity

const JOYSTICK_DEADZONE = 0.2

@onready var weapon: Weapon = null
@onready var camera: Camera2D = $Camera2D
@onready var timer_bar: ProgressBar = $Camera2D/CanvasLayer/TimeBar
@onready var bat_weapon: Weapon = null

var aim_direction: Vector2 = Vector2.RIGHT
var countdown_timer: float = 0.0


func _on_ready() -> void:
	print("Player _on_ready() called")
	# Set up inherited animated sprite reference
	animated_sprite = $AnimatedSprite2D
	# Try to find the weapon node
	weapon = get_node_or_null("TomatoGun")
	# Optional melee/AOE weapon (Enter)
	bat_weapon = get_node_or_null("BatSpinWeapon")
	add_to_group("player")
	if not weapon:
		push_error("No TomatoGun found as child of player. Weapon functionality will be disabled.")
		push_error("Add a TomatoGun node as a child of the Player node in the scene.")
	
	print("About to call setup_timer_bar()")
	setup_timer_bar()
	
func take_damage(amount: float, damage_source: Node = null) -> void:
	# Play hurt sound
	var hurt_sound = get_node_or_null("Hurt")
	if hurt_sound and hurt_sound is AudioStreamPlayer:
		hurt_sound.play()
	# 3 small vibration bursts for damage feedback
	vibrate_burst()

	modify_timer(-15.0)

func vibrate_burst() -> void:
	for i in range(3):
		Input.start_joy_vibration(0, 1, 0.7, 0.1)
		await get_tree().create_timer(0.5).timeout

func _physics_process(delta: float) -> void:
	handle_movement()
	handle_aim_direction()
	handle_attack()
	handle_animation()
	move_and_slide()
	handle_collisions()
	handle_timer_countdown(delta)

func handle_movement() -> void:
	# Get input from WASD/Arrow keys or left joystick
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("left", "right")
	input_vector.y = Input.get_axis("up", "down")
	
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
	
	# Bat spin attack with Enter key or gamepad X button
	if Input.is_action_just_pressed("bat_attack"):
		if bat_weapon:
			bat_weapon.attack(aim_direction)
		else:
			print("Cannot use bat attack: No bat weapon equipped")

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

func setup_timer_bar() -> void:
	print("setup_timer_bar() called")
	print("timer_bar reference: ", timer_bar)
	if not timer_bar:
		push_error("TimeBar not found in scene!")
		return
	
	# Timer bar is already in the correct CanvasLayer in the scene hierarchy
	# Just initialize it with 5 minutes (300 seconds)
	print("Calling timer_bar.setup_bar with 300.0")
	timer_bar.setup_bar.call_deferred(300.0)

# Public method to modify timer from other scripts
func modify_timer(delta_time: float) -> void:
	print("modify_timer() called with delta_time: ", delta_time)
	print("timer_bar is: ", timer_bar)
	if timer_bar:
		print("Calling timer_bar.change_value()")
		timer_bar.change_value(delta_time)
	else:
		print("ERROR: timer_bar is null!")

func handle_timer_countdown(delta: float) -> void:
	countdown_timer += delta
	if countdown_timer >= 1.0:
		print("Timer countdown tick - removing 1 second")
		countdown_timer -= 1.0
		$Node/Tickdown.play()
		modify_timer(-1.0)

# Override from LivingEntity to reduce timer when taking damage
func _on_damage_taken(amount: float, damage_source: Node) -> void:
	Input.start_joy_vibration(0, 0.8, 0.8, 0.9)
	modify_timer(-amount)
	# Vibrate controller for damage feedback
	
