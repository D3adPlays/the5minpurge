extends Weapon

## Melee / AOE weapon: press Enter to do a bat spin.

@export var effect_scene: PackedScene
@export var radius: float = 110.0
@export var spin_duration: float = 0.35
@export var spins: float = 1.0

func _ready() -> void:
	super._ready()
	if effect_scene == null:
		push_warning("BatSpinWeapon: effect_scene not assigned!")

func _do_attack(direction: Vector2) -> void:
	if not owner_node:
		return

	if effect_scene == null:
		return

	# Small controller vibration
	Input.start_joy_vibration(0, 0.2, 0.2, 0.08)

	var fx = effect_scene.instantiate()
	# Put the effect at the same level as the player (sibling) so it isn't scaled/rotated by the player.
	owner_node.get_parent().add_child(fx)
	fx.global_position = owner_node.global_position

	# Configure effect (damage + owner + radius)
	if fx.has_method("setup"):
		fx.setup(owner_node, damage, radius, spin_duration, spins)
	else:
		# Fallback if setup() wasn't found
		fx.set("owner_node", owner_node)
		fx.set("damage", damage)
		fx.set("radius", radius)
		fx.set("duration", spin_duration)
		fx.set("spins", spins)
