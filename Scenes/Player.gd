extends KinematicBody2D

export var is_being_detected = false

export var speed = 100

export var items = []

var map

puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()

puppet var sprite

func set_player_name(newName):
	$PlayerName.text = newName
	
	
func set_camera_limits():
	var tilemap = map.get_node("TileMap")
	var map_limits = tilemap.get_used_rect()
	var cell_size = tilemap.cell_size
	$Camera2D.limit_left = map_limits.position.x * cell_size.x
	$Camera2D.limit_right = map_limits.end.x * cell_size.x
	$Camera2D.limit_top = map_limits.position.y * cell_size.y
	$Camera2D.limit_bottom = map_limits.end.y * cell_size.y

func _ready():
	on_ready()

func on_ready():
	puppet_pos = position
	if is_network_master():
		$Camera2D.current = true
	map = get_tree().get_root().get_node("Match")
	set_camera_limits()


func _physics_process(delta):
	on_process(delta)
	
func on_process(delta):
	var motion = Vector2()

	if is_network_master():	
		if Input.is_action_pressed("move_left"):
			motion += Vector2(-1, 0)
		if Input.is_action_pressed("move_right"):
			motion += Vector2(1, 0)
		if Input.is_action_pressed("move_up"):
			motion += Vector2(0, -1)
		if Input.is_action_pressed("move_down"):
			motion += Vector2(0, 1)
		
		rset_unreliable("puppet_motion", motion)
		rset_unreliable("puppet_pos", position)
		rset("sprite", $AnimatedSprite)
	else:
		position = puppet_pos
		motion = puppet_motion
		
	if motion.length() > 0:	
		$AnimatedSprite.play()
		motion = motion.normalized()
		$AnimatedSprite.flip_h = motion.x < 0
		
	else:
		$AnimatedSprite.stop()
		
	move_and_slide(motion * speed)
	if not is_network_master():
		puppet_pos = position # To avoid jitter
		
	# limitar tela
	position.x = clamp(position.x, $Camera2D.limit_left + 32, $Camera2D.limit_right - 32)
	position.y = clamp(position.y, $Camera2D.limit_top + 32, $Camera2D.limit_bottom - 32)



func _on_DetectionArea_area_shape_entered(area_id, area, area_shape, self_shape):
	start_detection()
	

func _on_DetectionArea_area_shape_exited(area_id, area, area_shape, self_shape):
	stop_detection()
		
	
func start_detection():
	if !is_being_detected:
		is_being_detected = true
		
	
func stop_detection():
	if is_being_detected:
		is_being_detected = false

sync func game_over(winner):
	gamestate.game_over(winner)
