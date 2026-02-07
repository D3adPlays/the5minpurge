class_name TomatoGun
extends Weapon

# Tomato gun that shoots projectiles

@export var projectile_scene: PackedScene
@export var fire_rate: float = 0.5
@export var projectile_speed: float = 1000.0

func _ready() -> void:
	super._ready()
	if projectile_scene == null:
		push_warning("TomatoGun: projectile_scene not assigned!")

func _do_attack(direction: Vector2) -> void:
	# Create and fire a projectile
	print("TomatoGun firing!")
	
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
