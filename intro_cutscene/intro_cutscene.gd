extends Node2D

var letter_delay := 0.03

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
	$Music.stream = load("res://music/05 Bustling Town LOOP.wav")
	$Music.play()
	switch_images()

func typewriter_effect(message: String) -> void:
	$Message.text = ""
	for char in message:
		$Message.text += char
		await get_tree().create_timer(letter_delay).timeout

func show_message(message: String, wait_time: float = 2.0) -> void:
	Global.typing = true
	await typewriter_effect(message)
	Global.typing = false
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
	$SFX.stream = load("res://music/8-bit-gunshot.wav")
	$SFX.play()
	$Music.stop()
	
	await get_tree().create_timer(1.5).timeout

	await show_message(messages[1])

	
	await get_tree().create_timer(1.0).timeout

	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 1.0, 1.0)
	await tween.finished
	await get_tree().create_timer(1.0).timeout

	$DarkKingdom.visible = false
	$KingThrone.visible = true
	$FatedDice.visible = false
	$King.play()
	$King.visible = true
	$Dice.play()
	$Dice.visible = true
	$Message.text = ""
	$Music.stream = load("res://music/11 Lava Dungeon LOOP.wav")
	$Music.play()

	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 0.0, 1.0)

	show_message(messages[2])
	
	var tween_throne = create_tween()
	tween_throne.tween_property($KingThrone, "position:y", $KingThrone.position.y + 300, 6.0)
	
	var tween_king = create_tween()
	tween_king.tween_property($King, "position:y", $King.position.y + 300, 6.0)
	
	var tween_dice = create_tween()
	tween_dice.tween_property($Dice, "position:y", $Dice.position.y + 300, 6.0)

	await tween_throne.finished
	await tween_king.finished
	await tween_dice.finished
	await get_tree().create_timer(1.0).timeout

	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 1.0, 1.0)
	await tween.finished

	$KingThrone.visible = false
	$King.visible = false
	$Dice.visible = false
	$Message.text = ""
	$Suffer.visible = true

	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 0.0, 1.0)

	show_message(messages[3])
	
	var tween_suffer = $Suffer.create_tween()
	tween_suffer.tween_property($Suffer, "position:y", $Suffer.position.y - 100, 8.0)
	await tween_suffer.finished

	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 1.0, 1.0)
	await tween.finished

	$Suffer.visible = false
	$Message.text = ""
	$Village.visible = true
	$Player.visible = true
	$Player.play()
	$PlayerDice.visible = true
	$PlayerDice.play()

	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 0.0, 1.0)
	tween.finished

	show_message(messages[4])
	
	var tween_scale = $Village.create_tween()
	tween_scale.tween_property($Village, "scale", $Village.scale * 1.2, 5.0)
	await tween_scale.finished
	
	await get_tree().create_timer(1.0).timeout
	
	show_message(messages[5])
	
	await get_tree().create_timer(3.0).timeout

	tween = $Fade.create_tween()
	tween.tween_property($Fade, "modulate:a", 1.0, 1.0)
	await tween.finished
	var music_tween = $Music.create_tween()
	music_tween.tween_property($Music, "volume_db", -80, 1.0)
	await music_tween.finished
	
	const MAP_SCENE = preload("res://map_stuff/map_controller.tscn")
	get_tree().change_scene_to_packed(MAP_SCENE)
