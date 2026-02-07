class_name TomatoGun
extends Weapon

# Tomato gun that shoots projectiles

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 1000.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super._ready()
	if projectile_scene == null:
		push_warning("TomatoGun: projectile_scene not assigned!")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	# Rotate gun sprite to point towards aim direction
	if owner_node and owner_node.has_method("get"):
		var aim_dir = owner_node.get("aim_direction")
		if aim_dir and sprite:
			# Calculate angle from aim direction
			var angle = aim_dir.angle()
			sprite.rotation = angle + PI / 2  # Add 90 degrees to correct orientation
			
			# Position sprite with offset in aim direction
			sprite.position = aim_dir.normalized() * gun_offset
			
			# Flip sprite vertically if pointing left to avoid upside-down gun
			if abs(angle) > PI / 2:
				sprite.flip_v = true
			else:
				sprite.flip_v = false

func _do_attack(direction: Vector2) -> void:
	# Create and fire a projectile
	print("[TomatoGun] Firing weapon!")
	
	# Reduce timer by 1 second on shoot
	print("[TomatoGun] Getting player from tree...")
	var player = get_tree().get_first_node_in_group("player")
	print("[TomatoGun] Player found: ", player)
	
	if player:
		print("[TomatoGun] Player has modify_timer: ", player.has_method("modify_timer"))
		if player.has_method("modify_timer"):
			print("[TomatoGun] Calling player.modify_timer(-1.0)")
			player.modify_timer(-1.0)
			print("[TomatoGun] Timer modification complete")
		else:
			print("[TomatoGun] ERROR: Player doesn't have modify_timer method!")
	else:
		print("[TomatoGun] ERROR: Could not find player!")
	
	# Add controller vibration
	Input.start_joy_vibration(0, 0.3, 0.3, 0.1)
	
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		get_parent().add_sibling(projectile)
		# Apply offset in the direction of aim to spawn projectile away from player
		projectile.global_position = owner_node.global_position + (direction.normalized() * spawn_offset)
		
		# Set velocity using the projectile's method
		if projectile.has_method("set_velocity"):
			projectile.set_velocity(direction * projectile_speed)
		
		print("Projectile created at: ", projectile.global_position)
	else:
		print("No projectile scene assigned!")
