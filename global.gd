extends Node

var standard := load("res://dice/standard/standard_dice.tscn")
var risky := load("res://dice/risky/risky_dice.tscn")
var poison := load("res://dice/poison/poison_dice.tscn")
var healing := load("res://dice/healing/healing_dice.tscn")
var blinding := load("res://dice/blinding/blinding_dice.tscn")
var drowning := load("res://dice/drowning/drowning_dice.tscn")
var fire := load("res://dice/fire/fire_dice.tscn")
var char := load("res://dice/char/char_dice.tscn")
var chance := load("res://dice/chance/chance_dice.tscn")
var hypnosis := load("res://dice/hypnosis/hypnosis_dice.tscn")
var frozen := load("res://dice/frozen/frozen_dice.tscn")

var goblin := load("res://dummy_enemy/enemies/goblin/goblin.tscn")
var headsman := load("res://dummy_enemy/enemies/headsman/headsman.tscn")
var skeleton := load("res://dummy_enemy/enemies/skeleton/skeleton.tscn")
var knight := load("res://dummy_enemy/enemies/knight/knight.tscn")
var wolf := load("res://dummy_enemy/enemies/wolf/wolf.tscn")
var wizard := load("res://dummy_enemy/enemies/wizard/wizard.tscn")
var king := load("res://dummy_enemy/enemies/king/king.tscn")

var enemies_by_tier = {
	1: [goblin, skeleton],
	2: [knight, wolf],
	3: [headsman, wizard]
}



signal player_healed(heal_amount)

var coins := 20
var dummy_dice: Array = [standard, risky, poison, 
						  healing, blinding, drowning, 
						  fire, chance, hypnosis, 
						  frozen, ]

# testing dice for dice roller
var testing_dice : Array = [standard, standard, standard, standard, standard, healing]
var dice : Array = [chance, frozen, standard, poison, healing, standard]

var can_heal : bool = true
var difficulty: int = 0

enum Status { NOTHING, POISON, BLINDNESS, SHIELD, CURSE, BLEEDING, DROWNING, FIRE, HYPNOSIS, FROZEN}

const STATUS_PICS := {
	Status.POISON: "res://art/poison_effect.png",
	Status.BLINDNESS: "res://art/blindness_effect.png",
	Status.CURSE: "res://art/curse_effect.png",
	Status.BLEEDING: "res://art/bleeding_effect.png",
	Status.DROWNING: "res://art/water_effect.png",
	Status.FIRE: "res://art/fire_effect.png", 
	Status.HYPNOSIS: "res://art/hypnosis_effect.png",
	Status.FROZEN: "res://art/frozen_effect.png"
}

var shop_dict = {
	Dice.Type.STANDARD: standard,
	Dice.Type.RISKY: risky,
	Dice.Type.POISON: poison,
	Dice.Type.HEALING: healing,
	Dice.Type.BLIND: blinding,
	Dice.Type.DROWNING: drowning,
	Dice.Type.FIRE: fire,
	Dice.Type.CHANCE: chance, 
	Dice.Type.HYPNOSIS: hypnosis, 
	Dice.Type.FROZEN: frozen
}



var player_health = 200

var attempts = 0

func add_dice(new_die: Dice, type: Dice.Type) -> void:
	new_die.type = type
	
func spend(spent) -> void:
	coins -= spent

func heal(health) -> void:
	if can_heal:
		Global.player_health = min(Global.player_health + health, 200)
		player_healed.emit(health)
	else:
		Global.player_health = max(Global.player_health - health, 0)
		player_healed.emit(health)
		
func self_destruct() -> void:
	player_health = 0
	player_healed.emit(-999) 

# --- Audio Loading and Playback ---

# Preload the audio file.
var retro_audio = preload("res://music/Retro_Multiple_v5_wav.wav")
var audio_player: AudioStreamPlayer

# Boolean to control audio playback
var typing: bool = false

func _ready():
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = retro_audio
	# Set the volume to -6 dB (approximately 50% quieter than 0 dB)
	audio_player.volume_db = -18
	add_child(audio_player)
	
	# For Godot 4, if the audio stream supports looping, set its loop_mode to loop forward.
	if retro_audio.has_method("set_loop_mode"):
		retro_audio.loop_mode = 1

func _process(delta):
	# If typing is true and the audio is not playing, start playback.
	if typing and not audio_player.playing:
		audio_player.play()
	# If typing is false and the audio is playing, stop playback.
	elif not typing and audio_player.playing:
		audio_player.stop()

func reset() -> void:
	dice = [standard, standard, standard, standard, standard]
	player_health = 200
	coins = 200
	attempts += 1
	difficulty = 0
