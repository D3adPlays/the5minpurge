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
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		get_parent().add_sibling(projectile)
		projectile.global_position = owner_node.global_position
		projectile.gravity_scale = 0.0
		projectile.mass = 0.1
		# Handle different projectile types
		if projectile.has_method("set_velocity"):
			projectile.set_velocity(direction * projectile_speed)
		elif "linear_velocity" in projectile:
			projectile.linear_velocity = direction * projectile_speed
		elif "velocity" in projectile:
			projectile.velocity = direction * projectile_speed
		
		print("Projectile created at: ", projectile.global_position)
	else:
		print("No projectile scene assigned!")
