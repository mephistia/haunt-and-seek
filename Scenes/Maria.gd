extends "res://Scenes/Player.gd"

signal capturing

signal stopped_capturing

var cooldown = 8.0

var duration = 0.5

var can_capture = true

var is_detecting = false

var ghost

var distance = 0

var ghost_is_haunting = false

var max_captures = 3

onready var detection_area = get_node("DetectionArea/DetectionShape").shape.radius * 4.5

onready var fear_bar = get_tree().get_root().get_node("Match/CanvasLayer/GUI/HBoxContainer/VBoxContainer/FearProgress")

onready var captures_count = get_tree().get_root().get_node("Match/CanvasLayer/GUI/HBoxContainer/VBoxContainer/HBoxContainer2/CapturesCount")

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
	

func _process(delta):
	$RClickFeedback.text = "%3.1f" % $RClickTimer.time_left
	if is_detecting  and is_network_master() and ghost_is_haunting:
		distance = ghost.global_position.distance_to(global_position)
		
		var difference = detection_area - distance
		
		var increase_by = (1 - (distance / detection_area)) * 3
		fear_bar.value += increase_by
			
	# deve diminuir mesmo dentro da área
	elif is_network_master():
		fear_bar.value -= 1

func _input(event):
	.detect_inputs(event)
	if event.is_action_pressed("click_right") and can_capture and max_captures > 0:
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

func _on_Ghost_haunting():
	ghost_is_haunting = true

func _on_Ghost_stopped_haunting():
	ghost_is_haunting = false
