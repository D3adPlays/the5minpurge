extends Area2D

## Visual + hitbox effect for the bat spin.
## Spawned by BatSpinWeapon.

@export var radius: float = 110.0
@export var duration: float = 0.35
@export var spins: float = 1.0 # full turns during the duration

var damage: float = 25.0
var owner_node: Node2D = null

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var bat_sprite: AnimatedSprite2D = $BatSprite

var _elapsed: float = 0.0
var _hit_this_attack: Dictionary = {}

func setup(p_owner: Node2D, p_damage: float, p_radius: float, p_duration: float, p_spins: float) -> void:
	owner_node = p_owner
	damage = p_damage
	radius = p_radius
	duration = max(p_duration, 0.05)
	spins = max(p_spins, 0.1)

func _ready() -> void:
	# Ensure the collision radius matches the exported radius
	var circle := CircleShape2D.new()
	circle.radius = radius
	collision_shape.shape = circle

	monitoring = true
	monitorable = true

	# Start sprite anim if available
	if bat_sprite and bat_sprite.sprite_frames:
		bat_sprite.play()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(owner_node):
		queue_free()
		return

	_elapsed += delta

	# Follow the player
	global_position = owner_node.global_position

	# Rotate the bat around the player (the bat sprite itself is offset in the scene)
	rotation += (TAU * spins / duration) * delta

	# Damage enemies inside the circle (once per activation)
	_apply_damage_once()

	if _elapsed >= duration:
		queue_free()

func _apply_damage_once() -> void:
	# Check for both bodies (CharacterBody2D enemies) and areas (hitboxes)
	for body in get_overlapping_bodies():
		if body == owner_node:
			continue
		if not body.is_in_group("enemies"):
			continue
		if _hit_this_attack.has(body):
			continue

		_hit_this_attack[body] = true
		if body.has_method("take_damage"):
			body.take_damage(damage, owner_node)
	
	# Also check for enemy hitboxes (Area2D)
	for area in get_overlapping_areas():
		var enemy = area.get_parent()
		if not enemy or enemy == owner_node:
			continue
		if not enemy.is_in_group("enemies"):
			continue
		if _hit_this_attack.has(enemy):
			continue

		_hit_this_attack[enemy] = true
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage, owner_node)
