extends CharacterBody2D
class_name LivingEntity

## Base class for all living entities (player, enemies, NPCs)
## Provides common functionality for health, movement, and death

## Current health of the entity
@export var max_health: float = 10000.0
@export var current_health: float = 100.0

## Movement properties
@export var move_speed: float = 300.0

## Is the entity currently alive?
var is_alive: bool = true

## Reference to the animated sprite (must be set by child classes)
var animated_sprite: AnimatedSprite2D = null

## Reference to the collision shape for physics (movement blocking)
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

## Reference to the hitbox for damage detection (Area2D)
var hitbox: Area2D = null
var hitbox_collision_shape: CollisionShape2D = null

## Last movement direction for animation purposes
var last_movement_direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	add_to_group("living-entity")
	current_health = max_health
	
	# Setup hitbox reference
	hitbox = get_node_or_null("Hitbox")
	if hitbox:
		hitbox_collision_shape = hitbox.get_node_or_null("CollisionShape2D")
		# Connect the hitbox's owner to this entity for damage handling
		hitbox.add_to_group(name + "_hitbox")
	else:
		push_warning(name + ": No Hitbox node found. Add an Area2D named 'Hitbox' as a child.")
	
	_on_ready()

## Override this in child classes for custom initialization
func _on_ready() -> void:
	pass

## Get the player from the scene
## Searches through the entire scene tree, handles deferred calls if not found immediately
func get_player() -> Node2D:
	if not is_inside_tree():
		return null
	
	# Get from scene tree using groups
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0] as Node2D
	
	return null

## Take damage from an attack
func take_damage(amount: float, damage_source: Node = null) -> void:
	print("[", name, "] take_damage called - Amount: ", amount, " Source: ", damage_source.name if damage_source else "none")
	print("[", name, "] Current health: ", current_health, " Is alive: ", is_alive)
	
	if not is_alive:
		print("[", name, "] Already dead, ignoring damage")
		return
	
	current_health -= amount
	print("[", name, "] New health: ", current_health)
	_on_damage_taken(amount, damage_source)
	
	if current_health <= 0:
		die()
	#make the sprite blink red briefly to indicate damage taken
	if animated_sprite:
		animated_sprite.modulate = Color(1, 0.5, 0.5) # light red
		await get_tree().create_timer(0.1).timeout
		animated_sprite.modulate = Color(1, 1, 1) # reset to normal

## Heal the entity
func heal(amount: float) -> void:
	if not is_alive:
		return
	
	current_health = min(current_health + amount, max_health)
	_on_healed(amount)

## Kill the entity
func die() -> void:
	if not is_alive:
		return
	
	is_alive = false
	current_health = 0
	_on_death()

## Get normalized health (0.0 to 1.0)
func get_health_percentage() -> float:
	return current_health / max_health if max_health > 0 else 0.0

## Check if entity is at full health
func is_at_full_health() -> bool:
	return current_health >= max_health

## Handle animation based on velocity and movement direction
func handle_animation() -> void:
	if not animated_sprite:
		return
	
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

## Override these in child classes for custom behavior
func _on_damage_taken(amount: float, damage_source: Node) -> void:
	pass

func _on_healed(amount: float) -> void:
	pass

func _on_death() -> void:
	# Default death behavior
	if animated_sprite:
		animated_sprite.modulate = Color(1, 1, 1, 0.5)
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	if hitbox_collision_shape:
		hitbox_collision_shape.set_deferred("disabled", true)
	# Hide and disable the entity
	visible = false
	set_physics_process(false)
