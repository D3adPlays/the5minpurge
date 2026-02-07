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
	# Connect collision signal
	body_entered.connect(_on_body_entered)
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

## Override for custom behavior when lifetime expires
func _on_lifetime_expired() -> void:
	queue_free()
