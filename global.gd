extends Node

var standard := load("res://dice/standard/standard_dice.tscn")
var risky := load("res://dice/risky/risky_dice.tscn")
var poison := load("res://dice/poison/poison_dice.tscn")
var healing := load("res://dice/healing/healing_dice.tscn")
var blinding := load("res://dice/blinding/blinding_dice.tscn")

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

var coins := 0
var dummy_dice: Array = [standard, risky, poison, healing, blinding]

# testing dice for dice roller
var testing_dice : Array = [standard, standard, standard, standard, standard, healing]
var dice : Array = [standard, standard, standard, standard, standard]

var can_heal : bool = true
var difficulty: int = 0

enum Status { NOTHING, POISON, BLINDNESS, SHIELD, CURSE, BLEEDING }

const STATUS_PICS := {
	Status.POISON: "res://art/poison_effect.png",
	Status.BLINDNESS: "res://art/blindness_effect.png",
	Status.CURSE: "res://art/curse_effect.png",
	Status.BLEEDING: "res://art/bleeding_effect.png"
}

var shop_dict = {
	Dice.Type.STANDARD: standard,
	Dice.Type.RISKY: risky,
	Dice.Type.POISON: poison,
	Dice.Type.HEALING: healing,
	Dice.Type.BLIND: blinding
}


var shop_dice = [
	{"type": "standard", "price": 5, "description": "A standard six-sided dice."},
	{"type": "risky", "price": 10, "description": "A risky dice, designed to amplify the stakes."}
]

var player_health = 200

var attempts = 2

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
	audio_player.volume_db = -12
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
