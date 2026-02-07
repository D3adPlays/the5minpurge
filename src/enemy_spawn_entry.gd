extends Resource
class_name EnemySpawnEntry

@export var enemy_scene: PackedScene  # The enemy scene to spawn
@export var spawn_weight: float = 1.0  # Relative spawn weight (higher = more common)
@export var spawn_count: int = 1  # Number of this enemy type to spawn
