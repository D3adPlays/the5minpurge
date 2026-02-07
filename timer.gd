extends ProgressBar

var timer_label: Label
var progress_bg: ProgressBar

var current_time: float = 0.0
var max_time: float = 300.0  # 5 minutes default
var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get node references using direct paths instead of unique IDs
	timer_label = get_node_or_null("Timer")
	progress_bg = get_node_or_null("ProgressBG")
	
	print("Timer _ready() - timer_label: ", timer_label)
	print("Timer _ready() - progress_bg: ", progress_bg)
	
	show_percentage = false
	if progress_bg:
		progress_bg.show_percentage = false

# Setup the timer bar with a maximum time value
func setup_bar(p_max_time: float) -> void:
	print("Timer setup_bar called with max_time: ", p_max_time)
	max_time = p_max_time
	current_time = max_time
	max_value = max_time
	
	if progress_bg:
		progress_bg.max_value = max_time
	
	# Set initial values
	value = current_time
	if progress_bg:
		progress_bg.value = current_time
	
	update_timer_label()
	print("Timer initialized - current_time: ", current_time, ", label: ", timer_label)

# Change the timer value with optional smooth animation
func change_value(delta_time: float, animate: bool = true) -> void:
	var old_time = current_time
	current_time = clamp(current_time + delta_time, 0.0, max_time)
	
	print("Timer change_value: delta=", delta_time, " old=", old_time, " new=", current_time)
	
	# Create floating feedback label if delta is significant
	update_timer_label()
	if abs(delta_time) > 0.1:
		create_floating_label(delta_time)
	
	# Animate the progress bar smoothly
	if animate:
		animate_to_value(current_time)
	else:
		value = current_time
		if progress_bg:
			progress_bg.value = current_time
		

# Smoothly animate the progress bar to a target value
func animate_to_value(target_value: float) -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Animate both progress bars
	tween.tween_property(self, "value", target_value, 0.5)
	if progress_bg:
		tween.tween_property(progress_bg, "value", target_value, 0.5)
	
	# Update label smoothly during animation
	tween.set_parallel(false)
	tween.tween_method(update_timer_label_interpolated, value, target_value, 0.5)

# Update the timer label with formatted time
func update_timer_label() -> void:
	print("update_timer_label() called - timer_label: ", timer_label, ", current_time: ", current_time)
	if timer_label:
		var minutes = int(current_time) / 60
		var seconds = int(current_time) % 60
		var new_text = "%d:%02d" % [minutes, seconds]
		print("Setting timer_label.text to: ", new_text)
		timer_label.text = new_text
	else:
		print("ERROR: timer_label is null!")

# Update timer label during interpolation
func update_timer_label_interpolated(time_value: float) -> void:
	if timer_label:
		var minutes = int(time_value) / 60
		var seconds = int(time_value) % 60
		timer_label.text = "%d:%02d" % [minutes, seconds]

# Create an animated floating label showing the time delta
func create_floating_label(delta_time: float) -> void:
	var floating_label = Label.new()
	add_child(floating_label)
	
	# Position at the center
	
	
	# Format the text
	var sign = "+ " if delta_time > 0 else "- "
	var time_text = ""
	var abs_delta = abs(delta_time)
	
	if abs_delta >= 60:
		var minutes = int(abs_delta) / 60
		var seconds = int(abs_delta) % 60
		time_text = "%s%d:%02d" % [sign, minutes, seconds]
	else:
		time_text = "%s%ds" % [sign, int(abs_delta)]
	
	floating_label.text = time_text
	
	floating_label.position = Vector2((size.x / 2) - floating_label.size.x / 2, (size.y / 2) + 200)  # Start above the timer bar
	floating_label.pivot_offset = floating_label.size / 2
	
	# Set color based on positive/negative
	if delta_time > 0:
		floating_label.modulate = Color(0.2, 1.0, 0.2)  # Bright green
	else:
		floating_label.modulate = Color(1.0, 0.2, 0.2)  # Bright red
	
	# Style the label
	floating_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	floating_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Scale up for visibility (since parent is scaled down)
	floating_label.scale = Vector2(8.0, 8.0)
	
	# Add font size override for better visibility
	floating_label.add_theme_font_size_override("font_size", 32)
	
	# Animate the floating label
	var label_tween = create_tween()
	label_tween.set_parallel(true)
	
	# Move downwards
	label_tween.tween_property(floating_label, "position:y", 
		floating_label.position.y + 200, 1.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	# Fade out
	label_tween.tween_property(floating_label, "modulate:a", 0.0, 1.5).set_ease(Tween.EASE_IN)
	
	# Scale effect - start big, go smaller
	label_tween.tween_property(floating_label, "scale", Vector2(6.0, 6.0), 1.5).set_ease(Tween.EASE_IN)
	
	# Remove label after animation
	label_tween.tween_callback(floating_label.queue_free).set_delay(1.5)
