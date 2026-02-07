extends Projectile

func _on_projectile_ready() -> void:
	# Tomato-specific initialization
	target_groups = ["enemies"]

func _on_hit_target(target: Node) -> void:
	# Custom behavior when hitting a target
	print("Hit enemy: ", target.name)
