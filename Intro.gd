extends Node2D

func _ready() -> void:
	# Create a CanvasLayer for the intro screen
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	# Create black background
	var bg_rect = ColorRect.new()
	bg_rect.color = Color(0, 0, 0, 1.0)
	bg_rect.size = Vector2(1920, 1080)
	bg_rect.position = Vector2.ZERO
	canvas_layer.add_child(bg_rect)
	
	# Create first text label
	var text1 = Label.new()
	text1.text = "You crashed and found yourself stranded in the middle of zombies"
	text1.modulate = Color(1, 1, 1, 0)  # Start transparent
	text1.size = Vector2(1920, 400)
	text1.position = Vector2(0, 300)
	text1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text1.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text1.add_theme_font_size_override("font_size", 48)
	text1.autowrap_mode = TextServer.AUTOWRAP_WORD
	canvas_layer.add_child(text1)
	
	# Create second text label (ESCAPE in red)
	var text2 = Label.new()
	text2.text = "ESCAPE"
	text2.modulate = Color(1, 0, 0, 0)  # Start transparent, red color
	text2.size = Vector2(1920, 300)
	text2.position = Vector2(0, 600)
	text2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text2.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text2.add_theme_font_size_override("font_size", 72)
	canvas_layer.add_child(text2)
	
	# Animate first text fading in
	var tween1 = create_tween()
	tween1.tween_property(text1, "modulate:a", 1.0, 2.0)
	
	await tween1.finished
	
	# Animate second text fading in
	var tween2 = create_tween()
	tween2.tween_property(text2, "modulate:a", 1.0, 1.5)
	
	# Wait for total of 8 seconds from start
	await get_tree().create_timer(4.5).timeout
	
	# Transition to main scene
	get_tree().change_scene_to_file("res://main.tscn")

func _process(delta: float) -> void:
	pass
