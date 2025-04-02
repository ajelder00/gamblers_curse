extends Node2D

func _ready() -> void:
	$Varinshade.visible = true
	$DarkKingdom.visible = false
	$KingThrone.visible = false
	$King.visible = false
	$Dice.visible = false
	$Fade.visible = true
	$Village.visible = false
	$Player.visible = false
	$Player.flip_h = true
	$PlayerDice.visible = false
	
	switch_images()

func switch_images() -> void:
	# Fade out the Fade ColorRect (opaque to transparent over 1 second).
	var tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 0.0, 1.0)
	await tween.finished
	
	# Wait 10 seconds with Varinshade visible.
	await get_tree().create_timer(10.0).timeout
	$Varinshade.visible = false
	$DarkKingdom.visible = true
	
	# Wait 3 seconds with DarkKingdom visible.
	await get_tree().create_timer(3.0).timeout
	
	# Fade in to black over 1 second.
	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 1.0, 1.0)
	await tween.finished
	
	# Switch from DarkKingdom to KingThrone and play King and Dice.
	$DarkKingdom.visible = false
	$KingThrone.visible = true
	$King.play()
	$King.visible = true
	$Dice.play()
	$Dice.visible = true
	
	# Fade out to reveal KingThrone, King, and Dice.
	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 0.0, 1.0)
	
	# Pan down KingThrone.
	var tween_throne = create_tween()
	tween_throne.tween_property($KingThrone, "position:y", $KingThrone.position.y + 300, 8.0)
	
	# Pan down King.
	var tween_king = create_tween()
	tween_king.tween_property($King, "position:y", $King.position.y + 300, 8.0)
	
	# Pan down Dice.
	var tween_dice = create_tween()
	tween_dice.tween_property($Dice, "position:y", $Dice.position.y + 300, 8.0)
	
	# Wait for all panning tweens to finish.
	await tween_throne.finished
	await tween_king.finished
	await tween_dice.finished
	
	# Optionally wait for 3 seconds after the pan.
	await get_tree().create_timer(3.0).timeout
	
	# Fade in to black before switching to Village.
	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 1.0, 1.0)
	await tween.finished
	
	# Hide KingThrone, King, and Dice and show Village.
	$KingThrone.visible = false
	$King.visible = false
	$Dice.visible = false
	$Village.visible = true
	$Player.visible = true
	$Player.play()
	
	$PlayerDice.visible = true
	$PlayerDice.play()
	
	# Fade out from black to reveal Village.
	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 0.0, 1.0)
	await(6)
	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 1.0, 1.0)
	await tween.finished
	
