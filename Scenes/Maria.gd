extends "res://Scenes/Player.gd"

signal capturing

signal stopped_capturing

var cooldown = 8.0

var duration = 0.5

var can_capture = true

var is_detecting = false

var detecting = []

var ghost

var haunt_pos

var haunt_name

var distance = 0

var ghost_is_haunting = false

var max_captures = 3

var rotation_tween_ended = true

onready var detection_area = get_node("DetectionArea/DetectionShape").shape.radius * 4.5

onready var fear_bar = get_tree().get_root().get_node("Match/CanvasLayer/GUI/HBoxContainer/VBoxContainer/FearProgress")

onready var captures_count = get_tree().get_root().get_node("Match/CanvasLayer/GUI/HBoxContainer/VBoxContainer/HBoxContainer2/CapturesCount")

onready var sound_indicator = $Center/SoundIndicator


func _ready():
	gamestate.connect("game_started", self, "game_has_started")
	$RClickTimer.wait_time = cooldown	
	$RClickDuration.wait_time = duration
	$AnimatedSprite.animation = "maria"
	$RClickFeedback.hide()
	.on_ready() # Chamar função pai ("super")

func game_has_started():
	if is_network_master():
		ghost = get_parent().get_node("Ghost")
		if ghost:
			ghost.connect("haunting", self, "_on_Ghost_haunting")
			ghost.connect("stopped_haunting", self, "_on_Ghost_stopped_haunting")	

func _on_DetectionArea_area_shape_entered(area_id, area, area_shape, self_shape):
	.start_detection()
	is_detecting = true
	print(area.get_parent().get_name())
	print(area.get_parent().get_instance_id())
	
	if !detecting.has(area.get_parent().get_name()):
		detecting.append(area.get_parent().get_name())
	
# se pegar item q aumenta visão: $Light2D.texture_scale = 2	

func _process(delta):
	$RClickFeedback.text = "%3.1f" % $RClickTimer.time_left
	if is_network_master():
		# sempre mostra indicador
		if ghost_is_haunting:		
			
			sound_indicator.look_at(haunt_pos)
			sound_indicator.rotation_degrees += 90
			
		if detecting.has(haunt_name) and ghost_is_haunting:
			distance = haunt_pos.distance_to(global_position)
			print(haunt_pos)
			print(global_position)
			#distance = ghost.global_position.distance_to(global_position)
			var difference = detection_area - distance
			
			var increase_by = (1 - (distance / detection_area)) * 3
			fear_bar.value += increase_by
				
		# deve diminuir mesmo dentro da área
		else:
			fear_bar.value -= 0.1
		

func _input(event):
	if event.is_action_pressed("main_action") and can_capture and max_captures > 0:
		if is_network_master():
			$RClickTimer.start()
			$RClickDuration.start()
			$RClickFeedback.show()
			max_captures -= 1
			can_capture = false
			rpc("emit_capturing")
			

sync func emit_capturing():
	# feedback visual
	$AnimatedSprite.modulate = Color(1, 0, 0)
	emit_signal("capturing")
	
func _on_RClickTimer_timeout():
	$RClickFeedback.hide()
	can_capture = true

func _on_RClickDuration_timeout():
	rpc("emit_stopped_capturing")

	captures_count.text = str(max_captures)
	
	if max_captures == 0:
		var ghost_name = get_tree().get_root().get_node("Match/Players/Ghost/PlayerName").text
		rpc("game_over", "Fantasma (" + ghost_name + ")")
	
	
sync func emit_stopped_capturing():
	$AnimatedSprite.modulate = Color(1, 1, 1)
	emit_signal("stopped_capturing")

func _on_DetectionArea_area_shape_exited(area_id, area, area_shape, self_shape):
	.stop_detection()
	is_detecting = false
	detecting.erase(area.get_parent().get_name())
	

func _on_Ghost_haunting(name,pos):
	ghost_is_haunting = true
	haunt_name=name
	haunt_pos=pos
	print ("hunter is haunted")
	print("haunt_name " + str(haunt_name))
	$Tween.interpolate_property(sound_indicator, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property(sound_indicator, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.6, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.6)
	$Tween.interpolate_property(sound_indicator, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN, 1.2)
	$Tween.interpolate_property(sound_indicator, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.6, Tween.TRANS_LINEAR, Tween.EASE_OUT, 1.8)
	$Tween.start()
func _on_Ghost_stopped_haunting():
	ghost_is_haunting = false
	
	
