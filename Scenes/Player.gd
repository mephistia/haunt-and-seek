extends KinematicBody2D

export var speed = 100

export var items = []

var target = Vector2()
var velocity = Vector2()
var look_dir = Vector2(1, 0)

var map

puppet var puppet_pos = Vector2()
puppet var puppet_vel = Vector2()
puppet var puppet_target = Vector2()
puppet var sprite

func set_player_name(newName):
	$PlayerName.text = newName
	
	
func set_camera_limits():
	var tilemap = map.get_node("TileMap")
	var map_limits = tilemap.get_used_rect()
	var cell_size = tilemap.cell_size
	$Pivot/CamOffset/Camera2D.limit_left = map_limits.position.x * cell_size.x
	$Pivot/CamOffset/Camera2D.limit_right = map_limits.end.x * cell_size.x
	$Pivot/CamOffset/Camera2D.limit_top = map_limits.position.y * cell_size.y
	$Pivot/CamOffset/Camera2D.limit_bottom = map_limits.end.y * cell_size.y

func _ready():
	on_ready()

func on_ready():
	puppet_pos = position
	target = position
	puppet_target = target
	if is_network_master():
		$Pivot/CamOffset/Camera2D.current = true
	map = get_tree().get_root().get_node("Match")
	set_camera_limits()
	

func _input(event):
	if is_network_master():
		if event.is_action_pressed("click"):
			target = get_global_mouse_position()
		elif event is InputEventScreenTouch and event.pressed:
			target = event.position
		else:
			return
			
		rset("puppet_target", target)

func _physics_process(delta):
	on_process(delta)
	
func on_process(delta):
	# Trocar para click (navigation 2d):
	if is_network_master():	
		velocity = position.direction_to(target) * speed
		
		rset("puppet_vel", velocity)	
		rset_unreliable("puppet_pos", position)
		rset("sprite", $AnimatedSprite)
	else:
		position = puppet_pos
		velocity = puppet_vel
		target = puppet_target
		
	var camera_movement

	if (position.distance_to(target) > 10):
		velocity = move_and_slide(velocity)
		
		
	if velocity.length() > 0:
		$AnimatedSprite.play() # Pega node AnimatedSprite
		$AnimatedSprite.flip_h = velocity.x < 0
		# update look_dir
		if velocity.y > 0:
			# pra baixo
			look_dir = Vector2(0, 1)
		if velocity.y < 0:
			# pra cima
			look_dir = Vector2(0, -1)
		if velocity.x > 0:
			# pra direita
			look_dir = Vector2(1, 0)
		if velocity.x < 0:
			# pra esquerda
			look_dir = Vector2(-1, 0)
		
	else:
		$AnimatedSprite.stop()
		
		
	if not is_network_master():
		puppet_pos = position # To avoid jitter




