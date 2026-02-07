class_name Weapon
extends Node

# Abstract weapon class for all weapons

@export var attack_cooldown: float = 0.5
@export var damage: float = 10.0
@export var gun_offset: float = 70.0  # Offset in pixels from owner in aim direction
@export var spawn_offset: float = gun_offset + 40.0  # Offset in pixels from owner in aim direction

var can_attack: bool = true
var cooldown_timer: float = 0.0
var owner_node: Node2D

func _ready() -> void:
	owner_node = get_parent()

func _physics_process(delta: float) -> void:
	if cooldown_timer > 0:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			can_attack = true

# Override this method in subclasses
func attack(direction: Vector2) -> void:
	if can_attack:
		can_attack = false
		cooldown_timer = attack_cooldown
		_do_attack(direction)

func _do_attack(direction: Vector2) -> void:
	# Override in subclasses
	pass

func get_export_property(property: String) -> float:
	if "attack_cooldown" == property:
		return 0.5
	return 0.0
