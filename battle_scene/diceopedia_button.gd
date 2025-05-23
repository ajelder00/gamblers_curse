extends AnimatedSprite2D

var current_page_index := 0
var pages := []

func _ready() -> void:
	var diceopedia_rect = $DiceopediaRect
	diceopedia_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	diceopedia_rect.connect("mouse_entered", Callable(self, "_on_DiceopediaRect_mouse_entered"))
	diceopedia_rect.connect("mouse_exited", Callable(self, "_on_DiceopediaRect_mouse_exited"))
	diceopedia_rect.connect("gui_input", Callable(self, "_on_DiceopediaRect_gui_input"))
	play("idle")
	
	# Ensure DiceopediaBook is hidden initially.
	$DiceopediaBook.visible = false

func _on_DiceopediaRect_mouse_entered() -> void:
	play("open")

func _on_DiceopediaRect_mouse_exited() -> void:
	play_backwards("open")
	await animation_finished
	play("idle")

func _on_DiceopediaRect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		play("open_idle")
		
		# Fade in the DiceopediaBook child scene.
		var diceopedia_book = $DiceopediaBook
		diceopedia_book.visible = true
		
		# Start fully transparent.
		diceopedia_book.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(diceopedia_book, "modulate:a", 1.0, 0.5)
		
		# Show first page only
		$DiceopediaBook/BG.visible = true
		$DiceopediaBook/StatusBG.visible = false
		$DiceopediaBook/EnemyBG.visible = false

		# Connect the Back button press if not already connected.
		var back_button = diceopedia_book.get_node("Back")
		if not back_button.is_connected("pressed", Callable(self, "_on_Back_pressed")):
			back_button.connect("pressed", Callable(self, "_on_Back_pressed"))
			
			
		# Setup pages once and show first one
		pages = [
			diceopedia_book.get_node("BG"),
			diceopedia_book.get_node("StatusBG"),
			diceopedia_book.get_node("EnemyBG")
		]
		
		current_page_index = 0
		_show_page(current_page_index)
		
			
		# Connect the Next Page buttons if not already connected. 	
		var next_button = diceopedia_book.get_node("Next")
		if not next_button.is_connected("pressed", Callable(self, "_on_Next_pressed")):
			next_button.connect("pressed", Callable(self, "_on_Next_pressed"))

func _on_Back_pressed() -> void:
	# Fade out the DiceopediaBook when the Back button is pressed.
	var diceopedia_book = $DiceopediaBook
	var tween = create_tween()
	tween.tween_property(diceopedia_book, "modulate:a", 0.0, 0.5)
	await tween.finished
	diceopedia_book.visible = false
	
func _on_Next_pressed() -> void:
	current_page_index = (current_page_index + 1) % pages.size()
	_show_page(current_page_index)

func _show_page(index: int) -> void:
	for i in range(pages.size()):
		pages[i].visible = (i == index)
