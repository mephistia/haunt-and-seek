extends Area2D

export var speed = 100
var player_name = 'Player'
var screen_size


func _ready():
	screen_size = get_viewport_rect().size

func _process(delta):
	var velocity = Vector2()  # Vetor de movimento
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play() # Pega node AnimatedSprite
	else:
		$AnimatedSprite.stop()
		
	# Não passar da tela
	position += velocity * delta
	position.x = clamp(position.x, 0, (screen_size.x - 16))
	position.y = clamp(position.y, 0, (screen_size.y - 16))
	
	# Inverter sprite
	if velocity.x != 0:
		$AnimatedSprite.flip_h = velocity.x < 0



