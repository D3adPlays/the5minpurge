extends Area2D
class_name SpawnZone

@export var enemy_spawns: Array[EnemySpawnEntry] = []  # Array of enemy spawn entries (scene + weight)

var spawned_enemies: int = 0

func _ready():
	# Spawn all enemies on load
	spawn_all_enemies()

func spawn_all_enemies():
	if enemy_spawns.is_empty():
		push_error("No enemy spawns assigned to SpawnZone")
		return
	
	# Spawn all entries
	for spawn_entry in enemy_spawns:
		if not spawn_entry or not spawn_entry.enemy_scene:
			continue
		
		var spawn_amount = max(1, spawn_entry.spawn_count)
		for i in range(spawn_amount):
			spawn_enemy(spawn_entry)

func spawn_enemy(spawn_entry: EnemySpawnEntry):
	if not spawn_entry or not spawn_entry.enemy_scene:
		return
	
	# Get random position within the collision shape
	var spawn_position = get_random_position_in_zone()
	
	# Instance the enemy
	var enemy = spawn_entry.enemy_scene.instantiate()
	
	# Defer adding to tree and setting position
	var parent = get_parent()
	parent.add_child.call_deferred(enemy)
	call_deferred("_set_enemy_position", enemy, spawn_position)
	
	# Track spawned enemy
	spawned_enemies += 1
	
	# Connect to enemy death/removal if needed
	if enemy.has_signal("tree_exited"):
		enemy.tree_exited.connect(_on_enemy_removed)

func _set_enemy_position(enemy: Node2D, pos: Vector2):
	if is_instance_valid(enemy):
		enemy.global_position = pos

func get_random_position_in_zone() -> Vector2:
	# Assumes a CollisionShape2D child with RectangleShape2D
	var collision_shape = get_node_or_null("CollisionShape2D")
	if not collision_shape or not collision_shape.shape:
		return global_position
	
	if collision_shape.shape is RectangleShape2D:
		var rect_shape = collision_shape.shape as RectangleShape2D
		var extents = rect_shape.size / 2.0
		var random_offset = Vector2(
			randf_range(-extents.x, extents.x),
			randf_range(-extents.y, extents.y)
		)
		return global_position + random_offset
	
	# Fallback to center position
	return global_position

func _on_enemy_removed():
	spawned_enemies = max(0, spawned_enemies - 1)
