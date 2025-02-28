extends Button
@onready var parent = get_parent()
@onready var anim_player = parent.get_node("AnimationPlayer")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_credits_pressed)



func _on_credits_pressed():
	pass


func _on_mouse_entered() -> void:
	anim_player.play("big_credits")



func _on_mouse_exited() -> void:
	anim_player.play("small_credits")
