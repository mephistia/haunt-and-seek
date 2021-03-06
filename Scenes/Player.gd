extends KinematicBody2D

signal item_collected(which, by)

signal used_item(slot, type, who)

export var is_being_detected = false

export var speed = 100

export var items = []

var item_perceived

var map

puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()
puppet var puppet_is_facing_right = true

puppet var sprite

var is_paralyzed = false

var is_facing_right = true

var idle_animation_name

var moving_animation_name

func set_player_name(newName):
	$PlayerName.text = newName
	
func set_camera_limits():
	var tilemap = map.get_node("TileMapCollisions")
	var map_limits = tilemap.get_used_rect()
#	print("Map limits: ")
#	print(map_limits)
	var cell_size = tilemap.cell_size
	$Camera2D.limit_left = map_limits.position.x * cell_size.x
	$Camera2D.limit_right = map_limits.end.x * cell_size.x
	$Camera2D.limit_top = map_limits.position.y * cell_size.y
	$Camera2D.limit_bottom = map_limits.end.y * cell_size.y
	print($Camera2D.limit_left)
	print($Camera2D.limit_right)
	print($Camera2D.limit_top)
	print($Camera2D.limit_bottom)

func _ready():
	on_ready()

func on_ready():
	puppet_pos = position
	if is_network_master():
		$Camera2D.current = true
	map = get_tree().get_root().get_node("Match")
	set_camera_limits()
	
func useItem(itemId):
	pass
	

func _input(event):
	on_input(event)
	
func on_input(event):

	 # TODO: adicionar som de ação bloqueada
	if is_network_master():
		if event.is_action_pressed("item_1"):
			if range(items.size()).has(0):
				rpc("useItem", items[0])
				emit_signal("used_item", 1, self)
				items.remove(0)
			else:
				print("Slot vazio!")
		
		if event.is_action_pressed("item_2"):
			if range(items.size()).has(1):
				rpc("useItem", items[1])
				emit_signal("used_item", 2, self)
				items.remove(1)
			else:
				print("Slot vazio!")
				
		if event.is_action_pressed("tecla_3"):
			print("Detecting? " + str(is_being_detected))
		
		
func _physics_process(delta):
	if not is_paralyzed:
		on_process(delta)
	elif is_network_master():
		rset_unreliable("puppet_pos", position)
		rset_unreliable("puppet_motion", Vector2(0,0))
	
func on_process(delta):
	var motion = Vector2()

	if is_network_master():	
		if Input.is_action_pressed("move_left"):
			motion += Vector2(-1, 0)
			is_facing_right = false
		if Input.is_action_pressed("move_right"):
			motion += Vector2(1, 0)
			is_facing_right = true
		if Input.is_action_pressed("move_up"):
			motion += Vector2(0, -1)
		if Input.is_action_pressed("move_down"):
			motion += Vector2(0, 1)
		
		rset_unreliable("puppet_motion", motion)
		rset_unreliable("puppet_pos", position)
		rset_unreliable("puppet_is_facing_right", is_facing_right)
		rset("sprite", $AnimatedSprite)
	else:
		position = puppet_pos
		motion = puppet_motion
		is_facing_right = puppet_is_facing_right
		
		
	if motion.length() > 0:	
		$AnimatedSprite.play(moving_animation_name)
		motion = motion.normalized()
		
	else:
		$AnimatedSprite.play(idle_animation_name)
		
	$AnimatedSprite.flip_h = !is_facing_right
		
		
	move_and_slide(motion * speed)
	if not is_network_master():
		puppet_pos = position 
		
	# limitar tela
	position.x = clamp(position.x, $Camera2D.limit_left + 32, $Camera2D.limit_right - 32)
	position.y = clamp(position.y, $Camera2D.limit_top + 32, $Camera2D.limit_bottom - 32)

		
	
sync func start_detection():
		is_being_detected = true
		
	
sync func stop_detection():
		is_being_detected = false

sync func game_over(winner):
	gamestate.game_over(winner)


func _on_ItemArea_body_entered(body):
	if (body.is_in_group("Items") and is_network_master()):
		if (items.size() < 2):
			#body.get_node("Tooltip").show_tooltip()
			item_perceived = body
			items.append(item_perceived.type)
			emit_signal("item_collected", item_perceived, self)
			item_perceived = null
		else:
			#  TODO: adicionar som de ação bloqueada
			pass



func _on_ItemArea_body_exited(body):
	pass
