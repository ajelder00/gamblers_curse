extends AnimatedSprite2D

@export var speed: float = 200.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$".".play("idle")

	
func _physics_process(delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO

	# Check input for horizontal movement
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1

	# Check input for vertical movement
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1

	# If the player is moving, normalize direction and update position
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		position += direction * speed * delta
		
		# Play walking animation and flip sprite if moving left
		play("walk")
		flip_h = direction.x < 0
	else:
		# If no movement, play idle animation
		play("idle")
