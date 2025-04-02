extends Node2D

func _ready() -> void:
	$Varinshade.visible = true
	$DarkKingdom.visible = false
	$KingThrone.visible = false
	$King.visible = false
	$Fade.visible = true
	$Village.visible = false
	
	switch_images()

func switch_images() -> void:
	var tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 0.0, 1.0)
	await tween.finished
	
	await get_tree().create_timer(10.0).timeout
	$Varinshade.visible = false
	$DarkKingdom.visible = true

	await get_tree().create_timer(3.0).timeout
	
	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 1.0, 1.0)
	await tween.finished
	
	$DarkKingdom.visible = false
	$KingThrone.visible = true
	$King.play()
	$King.visible = true
	
	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 0.0, 1.0)
	
	var tween_throne = create_tween()
	tween_throne.tween_property($KingThrone, "position:y", $KingThrone.position.y + 300, 8.0)
	
	var tween_king = create_tween()
	tween_king.tween_property($King, "position:y", $King.position.y + 300, 8.0)
	
	await tween_throne.finished
	await tween_king.finished
	
	await get_tree().create_timer(3.0).timeout
	
	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 1.0, 1.0)
	await tween.finished
	
	$KingThrone.visible = false
	$King.visible = false
	$Village.visible = true
	
	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 0.0, 1.0)
	await tween.finished
