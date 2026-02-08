extends Area2D

var has_won = false

func _ready() -> void:
	# Connect to the body_entered signal to detect when player enters
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if has_won:
		return
	
	# Check if the player has already lost (lose condition triggered)
	var timer = get_tree().get_first_node_in_group("timer")
	if timer and timer.has_lost:
		return  # Don't trigger win if already lost
	
	# Check if the body is the player
	if body.is_in_group("player"):
		has_won = true
		trigger_win_sequence()

func trigger_win_sequence() -> void:
	# Mute all sounds
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	
	# Create a CanvasLayer for the fade and win message
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # Make sure it's on top
	get_tree().root.add_child(canvas_layer)
	
	# Create a black ColorRect for the fade
	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)  # Start transparent
	fade_rect.size = Vector2(1920, 1080)
	fade_rect.position = Vector2.ZERO
	canvas_layer.add_child(fade_rect)
	
	# Create the win message label
	var win_label = Label.new()
	win_label.text = "YOU ESCAPED! for now..."
	win_label.modulate = Color(1, 1, 1, 0)  # Start transparent
	win_label.size = Vector2(1920, 1080)
	win_label.position = Vector2.ZERO
	win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	win_label.add_theme_font_size_override("font_size", 72)
	canvas_layer.add_child(win_label)
	
	# Fade to black
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_rect, "color:a", 1.0, 2.0)
	
	# After fade to black, show win message
	await fade_tween.finished
	var text_tween = create_tween()
	text_tween.tween_property(win_label, "modulate:a", 1.0, 1.0)

func _process(delta: float) -> void:
	pass
