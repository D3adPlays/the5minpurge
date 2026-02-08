extends Area2D
class_name SpawnZone

@export var enemy_spawns: Array[EnemySpawnEntry] = []  # Array of enemy spawn entries (scene + weight)
@export var respawn_duration: float = 60.0  # Time in seconds to respawn all enemies
@export var enable_respawn: bool = true

var spawned_enemies: int = 0
var total_spawn_count: int = 0
var enemies_to_respawn: int = 0
var respawn_timer: float = 0.0
var respawn_interval: float = 0.0
var initial_spawn_done: bool = false

func _ready():
	# Calculate total spawn count
	for spawn_entry in enemy_spawns:
		if spawn_entry and spawn_entry.enemy_scene:
			total_spawn_count += max(1, spawn_entry.spawn_count)
	
	# Calculate respawn interval (spread respawns over the duration)
	if total_spawn_count > 0 and enable_respawn:
		respawn_interval = respawn_duration / float(total_spawn_count)
	
	# Spawn all enemies on load
	spawn_all_enemies()
	initial_spawn_done = true

func _process(delta: float):
	if not enable_respawn or not initial_spawn_done:
		return
	
	# Check if any enemies need to be respawned
	var missing_enemies = total_spawn_count - spawned_enemies
	if missing_enemies > 0:
		enemies_to_respawn = missing_enemies
	
	# Respawn enemies gradually
	if enemies_to_respawn > 0:
		respawn_timer += delta
		if respawn_timer >= respawn_interval:
			respawn_timer = 0.0
			respawn_next_enemy()
			enemies_to_respawn -= 1

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

func respawn_next_enemy():
	# Pick a random enemy type from the spawn list based on weights
	if enemy_spawns.is_empty():
		return
	
	# Calculate total weight
	var total_weight = 0
	for spawn_entry in enemy_spawns:
		if spawn_entry and spawn_entry.enemy_scene:
			total_weight += max(1, spawn_entry.spawn_count)
	
	if total_weight == 0:
		return
	
	# Pick random spawn entry
	var random_value = randf() * total_weight
	var cumulative_weight = 0
	
	for spawn_entry in enemy_spawns:
		if not spawn_entry or not spawn_entry.enemy_scene:
			continue
		
		cumulative_weight += max(1, spawn_entry.spawn_count)
		if random_value <= cumulative_weight:
			spawn_enemy(spawn_entry)
			return

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
