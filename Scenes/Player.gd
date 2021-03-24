extends Area2D

export var speed = 100

var player_name = 'Player'
var screen_size

export var items = []


func _ready():
	on_ready()

func on_ready():
	screen_size = get_viewport_rect().size
	# Seta a config como de puppet (client), com nome customizável
	rset_config("position", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("sprite", MultiplayerAPI.RPC_MODE_PUPPET)
	$PlayerName.text = player_name
	
func _process(delta):
	on_process(delta)
	
func on_process(delta):
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
		
	# Atualizar	
	if(is_network_master()):
		_synchronize()

func _synchronize():
	rset("position", position) # Atualizar o valor da config
	rset("sprite", $AnimatedSprite)

