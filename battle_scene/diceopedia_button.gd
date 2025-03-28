extends AnimatedSprite2D

func _ready() -> void:
	var diceopedia_rect = $DiceopediaRect
	diceopedia_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	diceopedia_rect.connect("mouse_entered", Callable(self, "_on_DiceopediaRect_mouse_entered"))
	diceopedia_rect.connect("mouse_exited", Callable(self, "_on_DiceopediaRect_mouse_exited"))
	diceopedia_rect.connect("gui_input", Callable(self, "_on_DiceopediaRect_gui_input"))
	play("idle")
	# Set the default scale to 0.283.
	scale = Vector2(0.283, 0.283)
	# Ensure DiceopediaBook is hidden initially.
	$DiceopediaBook.visible = false

func _on_DiceopediaRect_mouse_entered() -> void:
	play("open")
	# Tween the scale to 0.31 when the mouse enters.
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.31, 0.31), 0.3)

func _on_DiceopediaRect_mouse_exited() -> void:
	play("close")
	# Tween the scale back to 0.283 when the mouse exits.
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.283, 0.283), 0.3)
	await animation_finished
	play("idle")

func _on_DiceopediaRect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		play("open_idle")
		# Fade in the DiceopediaBook child scene.
		var diceopedia_book = $DiceopediaBook
		diceopedia_book.visible = true
		# (Optional) Reset its scale if you want it unaffected by the parent's scale:
		# diceopedia_book.scale = Vector2(1, 1)
		# Start with fully transparent.
		diceopedia_book.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(diceopedia_book, "modulate:a", 1.0, 0.5)
		# Connect the Back button press if not already connected.
		var back_button = diceopedia_book.get_node("Back")
		if not back_button.is_connected("pressed", Callable(self, "_on_Back_pressed")):
			back_button.connect("pressed", Callable(self, "_on_Back_pressed"))

func _on_Back_pressed() -> void:
	# Fade out the DiceopediaBook when the Back button is pressed.
	var diceopedia_book = $DiceopediaBook
	var tween = create_tween()
	tween.tween_property(diceopedia_book, "modulate:a", 0.0, 0.5)
	await tween.finished
	diceopedia_book.visible = false
