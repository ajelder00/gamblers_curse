extends Node2D

# Time delay between each letter for the typewriter effect.
var letter_delay := 0.05

# The messages corresponding to each scene.
var messages = [
	"> VARINSHADE WAS ONCE A BEAUTIFUL KINGDOM, WHERE ALL DECISIONS WERE MADE BY THE FATED DICE.",
	"> NOW, DARKNESS FALLS UPON THE LAND.",
	"> THE EVIL KING RULES WITH CURSED DICE, BENDING FATE TO HIS EVIL TYRANNICAL WILL...",
	"> DUE TO THE EVIL KING'S ACTIONS, VARINSHADE IS GRIPPED BY SUFFERING AND DESPAIR...",
	"> YOU, THE FATED ONE, RISES WITH YOUR OWN DICE TO FIGHT AGAINST THE KING.",
	"> IMMUNE TO THE CURSE, YOU SEEK FREEDOM FOR ALL..."
]

func _ready() -> void:
	$Varinshade.visible = true
	$DarkKingdom.visible = false
	$KingThrone.visible = false
	$King.visible = false
	$Dice.visible = false
	$Fade.visible = true
	$Village.visible = false
	$Suffer.visible = false
	$Player.visible = false
	$Player.flip_h = true
	$PlayerDice.visible = false
	$FatedDice.visible = true
	$FatedDice.play()
	
	
	switch_images()

func typewriter_effect(message: String) -> void:
	$Message.text = ""
	for char in message:
		$Message.text += char
		await get_tree().create_timer(letter_delay).timeout

func show_message(message: String, wait_time: float = 2.0) -> void:
	await typewriter_effect(message)
	await get_tree().create_timer(wait_time).timeout

func switch_images() -> void:
	var tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 0.0, 1.0)
	await tween.finished

	await show_message(messages[0])
	
	await get_tree().create_timer(1.0).timeout
	$Varinshade.visible = false
	$FatedDice.animation = "default"
	$DarkKingdom.visible = true

	await(1)
	await show_message(messages[1])
	
	await get_tree().create_timer(1.0).timeout

	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 1.0, 1.0)
	await tween.finished

	$DarkKingdom.visible = false
	$KingThrone.visible = true
	$FatedDice.visible = false
	$King.play()
	$King.visible = true
	$Dice.play()
	$Dice.visible = true
	$Message.text = ""

	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 0.0, 1.0)

	# KingThrone text
	show_message(messages[2])
	
	# Pan down KingThrone
	var tween_throne = create_tween()
	tween_throne.tween_property($KingThrone, "position:y", $KingThrone.position.y + 300, 8.0)

	# Pan down King
	var tween_king = create_tween()
	tween_king.tween_property($King, "position:y", $King.position.y + 300, 8.0)

	# Pan down Dice
	var tween_dice = create_tween()
	tween_dice.tween_property($Dice, "position:y", $Dice.position.y + 300, 8.0)

	await tween_throne.finished
	await tween_king.finished
	await tween_dice.finished
	await get_tree().create_timer(1.0).timeout

	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 1.0, 1.0)
	await tween.finished

	# Hide KingThrone, King, and Dice.
	$KingThrone.visible = false
	$King.visible = false
	$Dice.visible = false
	$Message.text = ""
	# Switch to Suffer
	$Suffer.visible = true

	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 0.0, 1.0)

	# suffer message
	show_message(messages[3])
	
	# suffer pan
	var tween_suffer = $Suffer.create_tween()
	tween_suffer.tween_property($Suffer, "position:y", $Suffer.position.y - 300, 8.0)
	await tween_suffer.finished

	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 1.0, 1.0)
	await tween.finished

	# Hide Suffer
	$Suffer.visible = false
	$Message.text = ""
	$Village.visible = true
	$Player.visible = true
	$Player.play()
	$PlayerDice.visible = true
	$PlayerDice.play()

	# village transition
	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 0.0, 1.0)
	tween.finished

	# Village text
	show_message(messages[4])
	
	# Scale BG
	var tween_scale = $Village.create_tween()
	tween_scale.tween_property($Village, "scale", $Village.scale * 1.2, 5.0)
	await tween_scale.finished
	
	await show_message(messages[5])
	
	await(3)

	# Fade to black.
	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 1.0, 1.0)
	await tween.finished
