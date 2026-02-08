extends Node2D

func _ready() -> void:
	# Create a CanvasLayer for the fade effect
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # Make sure it's on top
	add_child(canvas_layer)
	
	# Create a black ColorRect that covers the screen
	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 1.0)  # Start fully black
	fade_rect.size = Vector2(1920, 1080)
	fade_rect.position = Vector2.ZERO
	canvas_layer.add_child(fade_rect)
	
	# Fade from black to transparent
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_rect, "color:a", 0.0, 1.5)
	
	# Remove the fade elements after animation
	await fade_tween.finished
	canvas_layer.queue_free()

func _process(delta: float) -> void:
	pass
