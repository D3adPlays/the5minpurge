extends ParallaxLayer

## Speed at which clouds move (pixels per second)
@export var cloud_speed: Vector2 = Vector2(20, 10)

func _process(delta: float) -> void:
	# Move the clouds by adjusting the motion_offset
	motion_offset += cloud_speed * delta
