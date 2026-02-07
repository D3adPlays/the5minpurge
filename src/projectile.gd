extends Area2D
class_name Projectile

## Base class for all projectiles (bullets, arrows, etc.)
## Provides common functionality for damage, lifetime, and collision handling

## Damage dealt by this projectile
@export var damage: float = 10.0

## How long the projectile lives before auto-destroying
@export var lifetime: float = 5.0

## Which groups can this projectile damage
@export var target_groups: Array[String] = ["enemies"]

## Should the projectile ignore the shooter?
@export var ignore_shooter: bool = true

## Initial velocity of the projectile
var velocity: Vector2 = Vector2.ZERO

## Reference to the node that shot this projectile
var shooter: Node = null

func _ready() -> void:
	# Connect collision signals
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	add_to_group("projectiles")
	
	# Call child initialization
	_on_projectile_ready()
	
	# Auto-destroy after lifetime expires
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		_on_lifetime_expired()

func _physics_process(delta: float) -> void:
	# Move the projectile using velocity
	position += velocity * delta

## Override this in child classes for custom initialization
func _on_projectile_ready() -> void:
	pass

## Set the velocity of the projectile
func set_velocity(vel: Vector2) -> void:
	velocity = vel

## Set who shot this projectile
func set_shooter(source: Node) -> void:
	shooter = source

## Handle collision with another body
func _on_body_entered(body: Node) -> void:
	if body == self:
		return
	if ignore_shooter and body == shooter:
		return
	if body.is_in_group("player") or body.is_in_group("projectiles"):
		return

	var is_valid_target = false
	for group in target_groups:
		if body.is_in_group(group):
			is_valid_target = true
			break
	
	if is_valid_target:
		if body.has_method("take_damage"):
			body.take_damage(damage, self as Node)
			_on_hit_target(body)

	_on_collision(body)
	
	if should_destroy_on_collision(body):
		queue_free()

## Override to customize when projectile is destroyed
func should_destroy_on_collision(body: Node) -> bool:
	return true

## Override for custom behavior when hitting a valid target
func _on_hit_target(target: Node) -> void:
	pass

## Override for custom behavior on any collision
func _on_collision(body: Node) -> void:
	pass

## Handle collision with a hitbox (Area2D)
func _on_area_entered(area: Area2D) -> void:
	print("[Projectile] Area collision with: ", area.name, " parent: ", area.get_parent().name if area.get_parent() else "none")
	
	# Check if this is a hitbox attached to a living entity
	var owner_entity = area.get_parent()
	if not owner_entity:
		return
	
	if ignore_shooter and owner_entity == shooter:
		print("[Projectile] Ignoring shooter's hitbox")
		return
	
	if owner_entity.is_in_group("player") or owner_entity.is_in_group("projectiles"):
		print("[Projectile] Ignoring player/projectile hitbox")
		return
	
	print("[Projectile] Entity groups: ", owner_entity.get_groups())
	print("[Projectile] Target groups: ", target_groups)
	
	var is_valid_target = false
	for group in target_groups:
		if owner_entity.is_in_group(group):
			is_valid_target = true
			print("[Projectile] Found matching group: ", group)
			break
	
	if is_valid_target:
		print("[Projectile] Valid target confirmed via hitbox!")
		if owner_entity.has_method("take_damage"):
			print("[Projectile] Dealing ", damage, " damage to ", owner_entity.name)
			owner_entity.take_damage(damage, self as Node)
			_on_hit_target(owner_entity)
			print("[Projectile] Destroying projectile after hitbox collision")
			queue_free()
		else:
			print("[Projectile] WARNING: Entity has no take_damage method!")
	else:
		print("[Projectile] Not a valid target")

## Override for custom behavior when lifetime expires
func _on_lifetime_expired() -> void:
	queue_free()
